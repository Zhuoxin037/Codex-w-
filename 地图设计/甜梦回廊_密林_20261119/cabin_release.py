"""Stage the lobby upgrade against the current release and update only its pack files."""

import argparse
from contextlib import contextmanager
import json
import msvcrt
from pathlib import Path, PurePosixPath
import shutil
from zipfile import ZipFile, ZIP_DEFLATED

import cabin_corner
from deploy_dimension import exchange
from world import NAME, RELEASE, WORK as DIMENSION_WORK, digest, native

WORK = DIMENSION_WORK.parent / "rogue_cabin_corner_20261122"
STAGED = WORK / "native/world"
BEFORE = WORK / "before_cabin.zip"
ADDON = "datapacks/zz_sweetdream_floor/"
TARGET = Path(json.loads((DIMENSION_WORK/"installed.json").read_text(encoding="utf-8"))["target"])


def stage():
    WORK.mkdir(exist_ok=True)
    if STAGED.exists():
        raise FileExistsError(STAGED)
    if not BEFORE.exists():
        shutil.copy2(RELEASE, BEFORE)
    with ZipFile(BEFORE) as archive:
        for name in archive.namelist():
            path = PurePosixPath(name)
            if path.is_absolute() or path.parts[0] != NAME or ".." in path.parts:
                raise ValueError(name)
            if not name.endswith("/"):
                exchange(STAGED.joinpath(*path.parts[1:]), archive.read(name))
    cabin_corner.stage(STAGED / ADDON)
    print(f"Staged {len(changes())} updated files", flush=True)


def changes():
    with ZipFile(BEFORE) as archive:
        originals = {key for key in archive.namelist() if key.startswith(f"{NAME}/{ADDON}") and not key.endswith("/")}
        current = {path.relative_to(STAGED).as_posix() for path in (STAGED / ADDON).rglob("*") if path.is_file()}
        result = {}
        for rel in sorted(current | {key.removeprefix(f"{NAME}/") for key in originals}):
            key = f"{NAME}/{rel}"
            before = archive.read(key) if key in originals else None
            after = (STAGED / rel).read_bytes() if rel in current else None
            if before != after:
                result[rel] = (before, after)
        return result


def configure_native():
    import world
    native.WORK = world.WORK = WORK
    native.NATIVE = WORK / "native"
    native.rcon.D = native.NATIVE
    world.WORLD = STAGED


def check():
    configure_native()
    import verify_dimension
    verify_dimension.main()


def pack():
    report = json.loads((WORK/"native_checks.json").read_text(encoding="utf-8"))
    if len(report) < 41 or not all(case["pass"] for case in report):
        raise RuntimeError("The lobby and Forest regression has not passed")
    updates = {f"{NAME}/{rel}": after for rel, (_, after) in changes().items()}
    interim = WORK / "release_cabin.zip"
    with ZipFile(BEFORE) as old, ZipFile(interim,"w",ZIP_DEFLATED,compresslevel=4) as new:
        for info in old.infolist():
            key = info.filename
            data = updates.pop(key) if key in updates else old.read(info)
            if data is not None:
                new.writestr(info,data)
        for key, data in updates.items():
            new.writestr(key,data)
    with ZipFile(interim) as archive:
        assert archive.testzip() is None
        assert not any("/playerdata/" in path for path in archive.namelist())
        for rel, (_,after) in changes().items():
            assert release_data(archive,rel)==after, rel
    exchange(RELEASE, interim.read_bytes())
    print("Published", RELEASE.name, digest(RELEASE), flush=True)


@contextmanager
def session_lock(path):
    with path.open("r+b") as lock:
        try:
            msvcrt.locking(lock.fileno(), msvcrt.LK_NBLCK, 1)
        except OSError as error:
            raise RuntimeError("The installed world is open. Close it before updating its pack.") from error
        try:
            yield
        finally:
            lock.seek(0)
            msvcrt.locking(lock.fileno(), msvcrt.LK_UNLCK, 1)


def release_data(archive,rel):
    try:
        return archive.read(f"{NAME}/{rel}")
    except KeyError:
        return None


def install(apply):
    target = TARGET.resolve(strict=True)
    if target.name != NAME or target.parent.name != "saves" or not (target/"level.dat").is_file():
        raise ValueError("Expected the existing Forest save")
    with ZipFile(RELEASE) as archive:
        rows = []
        for rel, (before, after) in changes().items():
            if release_data(archive,rel) != after:
                raise ValueError(f"Update the release before installing: {rel}")
            path = (target / rel).resolve()
            path.relative_to(target)
            rows.append((path, rel, before, after))

    def pending():
        result = []
        for path, rel, before, after in rows:
            data = path.read_bytes() if path.exists() else None
            if data not in (before, after):
                raise RuntimeError(f"Separate edit in installed world: {path}")
            if data != after:
                result.append((path, rel, before, after))
        return result

    if not apply:
        print(f"{len(pending())} installed pack files to update")
        return
    with session_lock(target/"session.lock"):
        todo = pending()
        completed = []
        try:
            for path, rel, before, after in todo:
                if before is not None:
                    exchange(WORK/"installed_before_cabin"/rel, before)
                if after is None:
                    path.unlink()
                else:
                    exchange(path, after)
                completed.append((path, before))
            if pending():
                raise RuntimeError("Installed files still differ")
        except BaseException:
            for path, before in reversed(completed):
                if before is None:
                    path.unlink(missing_ok=True)
                else:
                    exchange(path, before)
            raise
    (WORK/"installed.json").write_text(json.dumps({
        "target":str(target),"updated":len(todo),"zip_sha256":digest(RELEASE)
    },ensure_ascii=False,indent=2),encoding="utf-8")
    print(f"Installed and verified {len(todo)} pack files", flush=True)


if __name__=="__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("action",choices=("stage","start","check","pack","install","cmd"))
    parser.add_argument("value",nargs="?")
    parser.add_argument("--apply",action="store_true")
    args = parser.parse_args()
    if args.action in ("start","cmd"):
        configure_native()
        if args.action=="start":
            native.start()
        else:
            print(native.c(args.value))
    elif args.action=="install":
        install(args.apply)
    else:
        globals()[args.action]()
