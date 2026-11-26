"""Move map assets into the enabled resource pack before retiring world resources."""
from pathlib import Path, PurePosixPath
from tempfile import mkdtemp
from zipfile import ZipFile
import shutil

ROOT = Path(__file__).resolve().parents[2]
PROFILE = Path("D:/PCL 正式版 2.10.0/.minecraft/versions/1.21.5-Fabric 0.16.10")
WORLD = PROFILE / "saves" / "甜梦回廊·密林"
PACK_NAME = "fallendream_rp_完整版"
MASTER = ROOT / PACK_NAME
ENABLED = PROFILE / "resourcepacks" / PACK_NAME


def migrate():
    archive = WORLD / "resources.zip"
    if not archive.is_file():
        print("World resources already absent.")
        return
    if not (ENABLED / "pack.mcmeta").is_file():
        raise RuntimeError("Enabled pack folder missing")
    if 'file/' + PACK_NAME not in (PROFILE / "options.txt").read_text(encoding="utf-8"):
        raise RuntimeError("Full resource pack is not selected")
    copied = 0
    with ZipFile(archive) as bundle:
        for info in bundle.infolist():
            if info.is_dir():
                continue
            relative = PurePosixPath(info.filename)
            if len(relative.parts) < 3 or relative.parts[0] != "assets":
                continue
            if relative.is_absolute() or ".." in relative.parts or "\\" in info.filename:
                raise ValueError(info.filename)
            original = MASTER.joinpath(*relative.parts)
            target = ENABLED.joinpath(*relative.parts)
            map_asset = relative.parts[1] in {"fallenroute", "drawlab"}
            if map_asset and not original.exists():
                original.parent.mkdir(parents=True, exist_ok=True)
                original.write_bytes(bundle.read(info))
            if original.is_file() and (map_asset or not target.exists()):
                if not target.is_file() or target.read_bytes() != original.read_bytes():
                    target.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copyfile(original, target)
                    copied += 1
                if target.read_bytes() != original.read_bytes():
                    raise RuntimeError(f"Verification failed for {relative}")
    backup = Path(mkdtemp(prefix="world_resource_backup_", dir=ROOT / ".workbuddy")) / archive.name
    archive.replace(backup)
    print(f"Verified pack, copied {copied} files, moved archive to {backup}")


if __name__ == "__main__":
    migrate()
