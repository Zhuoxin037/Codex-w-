"""Update the installed Forest pack in place while retaining the existing lobby and save data."""
import argparse
import json
import os
from pathlib import Path
import shutil
import tempfile
from zipfile import ZipFile

from world import NAME, RELEASE, WORK, digest
from floor_upgrade import MAP_ID

BACKUP = WORK / "before_dimension.zip"
ADDON = "datapacks/zz_sweetdream_floor/"
MAP = f"data/map_{MAP_ID}.dat"


def backup_release():
    if not BACKUP.exists():
        shutil.copy2(RELEASE,BACKUP)
    print("Saved the previous release",digest(BACKUP))


def exchange(target, data):
    target.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=target.parent,delete=False) as stream:
        temporary=Path(stream.name)
        stream.write(data)
    try:
        os.replace(temporary,target)
    finally:
        temporary.unlink(missing_ok=True)


def change_set(target):
    rows=[]
    if not (target/"level.dat").is_file() or target.name!=NAME or target.parent.name!="saves":
        raise ValueError("Expected the installed Forest save")
    with ZipFile(BACKUP) as previous, ZipFile(RELEASE) as release:
        old=set(previous.namelist())
        for key in release.namelist():
            rel=key.removeprefix(NAME+"/")
            if not (rel.startswith(ADDON) or rel==MAP):
                continue
            path=(target/rel).resolve()
            path.relative_to(target)
            before=previous.read(key) if key in old else None
            after=release.read(key)
            if before==after:
                continue
            current=path.read_bytes() if path.exists() else None
            if current not in (before,after):
                raise ValueError(f"The installed copy has a separate edit: {path}")
            if current!=after:
                rows.append((path,current,after))
    return rows


def apply(target):
    target=target.resolve(strict=True)
    rows=change_set(target)
    completed=[]
    try:
        for path,before,after in rows:
            if before is not None:
                backup=WORK/"installed_before_dimension"/path.relative_to(target)
                if not backup.exists():
                    exchange(backup,before)
            exchange(path,after)
            completed.append((path,before))
        if change_set(target):
            raise RuntimeError("The installed data still differs")
    except BaseException:
        for path,before in reversed(completed):
            if before is None:
                path.unlink(missing_ok=True)
            else:
                exchange(path,before)
        raise
    (WORK/"installed.json").write_text(json.dumps({
        "target":str(target),"updated":len(completed),"zip_sha256":digest(RELEASE)
    },ensure_ascii=False,indent=2),encoding="utf-8")
    print(f"{len(completed)} updates applied and verified against the release")


if __name__=="__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("target",type=Path,nargs="?")
    parser.add_argument("--apply",action="store_true")
    args=parser.parse_args()
    if args.target is None:
        backup_release()
    elif args.apply:
        apply(args.target)
    else:
        print(f"{len(change_set(args.target.resolve(strict=True)))} changes for the installed copy")
