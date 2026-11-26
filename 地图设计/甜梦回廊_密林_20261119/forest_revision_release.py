"""Package the Forest changes and install only changed add-on files in PCL."""

import argparse
import hashlib
import json
import msvcrt
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

from deploy_dimension import exchange
from floor_upgrade import write
from forest_combat import moss_hurt_commands
from forest_places import stage as places
from forest_room_services import stage as rooms
from forest_services import stage as services
from world import ROOT

WORK = ROOT / ".workbuddy/rogue_forest_revision_20261123"
RELEASES = ROOT / "outputs/01a1f2ce-e657-7782-ac13-28be248b8f29"
BASE = RELEASES / "坠梦_大厅与研习更新版.zip"
ZIP = RELEASES / "坠梦_密林修订版.zip"
ADDON = "datapacks/zz_sweetdream_floor/"
TARGET = Path("D:/PCL 正式版 2.10.0/.minecraft/versions/1.21.5-Fabric 0.16.10/saves/甜梦回廊·密林")


def unpack(source, destination):
    with ZipFile(source) as archive:
        for item in archive.infolist():
            path = Path(item.filename.partition("/")[2])
            if item.is_dir() or not path.parts:
                continue
            if path.is_absolute() or ".." in path.parts:
                raise ValueError(item.filename)
            dest = destination / path
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes(archive.read(item))


def stage(folder):
    unpack(BASE, folder)
    places(folder)
    services(folder)
    rooms(folder)
    write(folder / ADDON / "data/sweetdream_floor/function/combat/mobs/moss_hurt.mcfunction",
          "\n".join(moss_hurt_commands()))


def addon_diff(folder):
    with ZipFile(BASE) as archive:
        previous = {item.partition("/")[2]: archive.read(item) for item in archive.namelist()
                    if item.partition("/")[2].startswith(ADDON) and not item.endswith("/")}
    return {p.relative_to(folder).as_posix(): (previous.get(p.relative_to(folder).as_posix()), p.read_bytes())
            for p in (folder / ADDON).rglob("*") if p.is_file()
            and previous.get(p.relative_to(folder).as_posix()) != p.read_bytes()}


def publish(folder):
    staged = addon_diff(folder)
    with ZipFile(BASE) as source, ZipFile(ZIP, "w", ZIP_DEFLATED, compresslevel=4) as target:
        for item in source.infolist():
            relative = item.filename.partition("/")[2]
            if not item.is_dir() and relative not in staged:
                target.writestr("坠梦_密林修订版/"+relative,source.read(item),compress_type=item.compress_type)
        for relative,(_,after) in staged.items():
            target.writestr("坠梦_密林修订版/"+relative,after)
    # The distributed copy must have exactly one world root.
    with ZipFile(ZIP) as archive:
        assert archive.testzip() is None
        assert {name.split("/")[0] for name in archive.namelist()} == {"坠梦_密林修订版"}
        for relative,(_,after) in staged.items():
            assert archive.read("坠梦_密林修订版/"+relative)==after, relative
    print(ZIP.name, len(staged), hashlib.sha256(ZIP.read_bytes()).hexdigest())


def install(folder):
    target = TARGET.resolve(strict=True)
    assert target.parent.name == "saves" and (target/"level.dat").is_file()
    delta = addon_diff(folder)
    pending = []
    with (target/"session.lock").open("r+b") as lock:
        msvcrt.locking(lock.fileno(), msvcrt.LK_NBLCK, 3)
        for relative,(before,after) in delta.items():
            path=(target/relative).resolve()
            path.relative_to(target)
            installed = path.read_bytes() if path.exists() else None
            if installed not in (before,after):
                raise RuntimeError(f"The live save contains independent edits: {relative}")
            if installed != after:
                pending.append((relative,path,installed,after))
        with ZipFile(WORK/"before_install.zip","w",ZIP_DEFLATED) as backup:
            for relative,_,installed,_ in pending:
                if installed is not None:
                    backup.writestr(relative,installed)
        done = []
        try:
            for relative,path,installed,after in pending:
                exchange(path,after)
                done.append((path,installed))
            for relative,(_,after) in delta.items():
                assert (target/relative).read_bytes()==after, relative
        except BaseException:
            for path,installed in reversed(done):
                if installed is None:
                    path.unlink(missing_ok=True)
                else:
                    exchange(path,installed)
            raise
    (WORK/"installed.json").write_text(json.dumps({"target":str(target),"changed":len(pending),
        "verified":len(delta),"package":str(ZIP)},ensure_ascii=False,indent=2),encoding="utf-8")
    print(f"Installed {len(pending)} files, verified {len(delta)} in {target}")


if __name__ == "__main__":
    cli=argparse.ArgumentParser()
    cli.add_argument("action",choices=("stage","publish","install"))
    cli.add_argument("folder",type=Path)
    opts=cli.parse_args()
    globals()[opts.action](opts.folder)
