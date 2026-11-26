"""Assemble the verified clean starter save, or install it into a new save directory."""
from pathlib import Path
import argparse
import gzip
import hashlib
import json
import shutil
import struct
import tempfile
from zipfile import ZIP_STORED, ZIP_DEFLATED, ZipFile

from build import HERE, WORK, WORLD

NAME = "甜梦回廊_首层试玩"
ZIP = HERE / f"{NAME}.zip"


def rename_world(path):
    raw = gzip.decompress(path.read_bytes())
    old = b"\x08\x00\x09LevelName\x00\x05world"
    name = NAME.encode()
    new = b"\x08\x00\x09LevelName" + struct.pack(">H", len(name)) + name
    if raw.count(old) != 1:
        raise ValueError("Unexpected starter level name")
    path.write_bytes(gzip.compress(raw.replace(old, new, 1), mtime=0))


def assemble():
    with tempfile.TemporaryDirectory(prefix="release_", dir=WORK) as scratch:
        new = Path(scratch) / NAME
        shutil.copytree(WORK / "starter", new)
        shutil.copytree(WORLD / "datapacks", new / "datapacks")
        shutil.copy2(WORLD / "resources.zip", new / "resources.zip")
        rename_world(new / "level.dat")
        outfile = Path(scratch) / ZIP.name
        with ZipFile(outfile, "w", ZIP_DEFLATED, compresslevel=4) as out:
            for item in sorted(new.rglob("*")):
                if item.is_file():
                    method = ZIP_STORED if item.suffix in {".zip", ".mca"} else ZIP_DEFLATED
                    out.write(item, item.relative_to(new.parent).as_posix(), compress_type=method)
        with ZipFile(outfile) as out:
            bad = out.testzip()
            assert bad is None, bad
            for member in ("level.dat", "resources.zip", "data/map_1900102900.dat", "datapacks/manacore-1.0.0/pack.mcmeta", "datapacks/sweetdream/pack.mcmeta", "datapacks/zz_sweetdream_floor/pack.mcmeta"):
                assert f"{NAME}/{member}" in out.namelist(), member
        shutil.copy2(outfile, ZIP)
    print(f"{ZIP.stat().st_size:,} bytes | sha256 {hashlib.file_digest(ZIP.open('rb'), 'sha256').hexdigest()}")


def install(parent):
    parent = parent.resolve(strict=True)
    target = parent / NAME
    if parent.name != "saves" or target.exists():
        raise ValueError("Expected a saves directory and a new, unused target name")
    with ZipFile(ZIP) as release, tempfile.TemporaryDirectory(prefix="install_", dir=WORK) as scratch:
        entries = release.namelist()
        for name in entries:
            path = Path(name)
            if path.is_absolute() or path.parts[0] != NAME or ".." in path.parts:
                raise ValueError(f"Unexpected archive path: {name}")
        release.extractall(scratch)
        copy = Path(scratch) / NAME
        shutil.copytree(copy, target)
        for item in copy.rglob("*"):
            if item.is_file():
                result = target / item.relative_to(copy)
                with item.open("rb") as original, result.open("rb") as deployed:
                    assert hashlib.file_digest(original, "sha256").digest() == hashlib.file_digest(deployed, "sha256").digest(), result
    print(target)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--install", type=Path)
    args = parser.parse_args()
    if args.install:
        install(args.install)
    else:
        assemble()
