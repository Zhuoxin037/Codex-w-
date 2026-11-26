"""Stage a standalone Sweetdream floor pack and world resources from the current workspace."""
from pathlib import Path
from collections import Counter
import gzip
import json
import re
import shutil
import struct
from zipfile import ZipFile, ZIP_DEFLATED
import argparse

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
WORK = ROOT / ".workbuddy/rogue_floor_20261119"
WORLD = WORK / "native" / "world"
ADDON = WORLD / "datapacks/zz_sweetdream_floor"
BASE = WORLD / "datapacks/sweetdream/data/sweetdream/function"
NS = ADDON / "data/sweetdream_floor"
SOURCE = ROOT / "sweetdream/data/sweetdream/function"


def write(path, body):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(body.rstrip() + "\n", encoding="utf-8")


def mc(name, body):
    write(NS / f"function/{name}.mcfunction", body)


def js(path, value):
    write(path, json.dumps(value, ensure_ascii=False, indent=2))


def generate_pool():
    text = ["data modify storage sweetdream_floor:pool entries set value []"]
    roles = Counter()
    files = (SOURCE / "equipment").glob("*/*/give.mcfunction")
    for path in sorted(files):
        raw = path.read_text(encoding="utf-8")
        data = re.search(r"(?:minecraft:)?custom_data=(\{[^{}\r\n]*zx:\[[^][]*\][^{}\r\n]*\})", raw)
        if not data:
            continue
        meta = data[1]
        profession = re.search(r"profession:(\d+)", meta)
        rarity = re.search(r'rarity:"t([1-5])"', meta)
        tags = re.search(r'tags:(\[[^]]*\])', meta)
        category, item, _ = path.relative_to(SOURCE / "equipment").parts
        record = {
            "id": item,
            "category": category,
            "job": int(profession[1]) if profession else 0,
            "tier": int(rarity[1]) if rarity else 1,
            "tags": json.loads(tags[1]) if tags else [],
            "fn": f"sweetdream:equipment/{category}/{item}/give",
        }
        if category not in {"sword", "axe", "bow", "staff", "armor", "tool", "offhand"}:
            continue
        roles.update([category])
        text.append("data modify storage sweetdream_floor:pool entries append value " + json.dumps(record, ensure_ascii=False, separators=(",", ":")))
    mc("pool/load", "\n".join(text))
    print("Equipment records", len(text) - 1, dict(roles))
    return len(text) - 1


def stage():
    for pack in ("manacore-1.0.0", "sweetdream"):
        shutil.copytree(ROOT / pack, WORLD / "datapacks" / pack, dirs_exist_ok=True)
    shutil.copytree(HERE / "floor_pack", ADDON, dirs_exist_ok=True)
    for path in (BASE / "rogue").rglob("*.mcfunction"):
        body = path.read_text(encoding="utf-8")
        write(path, body.replace("sweetdream:rogue_preview", "minecraft:overworld"))
    # Guarantee the functional rooms and a reasonable fighting route in the test layer.
    assign = BASE / "rogue/gen/assign.mcfunction"
    current = assign.read_text(encoding="utf-8")
    start = current.index('function sweetdream:rogue/gen/assign_one {kind:"safe"}')
    essentials = ["safe", "merchant", "forge", "astrology", "elite", "event", "gamble", "rental", "blackmarket", "combat", "combat", "combat"]
    write(assign, current[:start] + "\n".join(f'function sweetdream:rogue/gen/assign_one {{kind:"{room}"}}' for room in essentials) + "\nfunction sweetdream:rogue/gen/assign_rest")
    overdraw = BASE / "rogue/prototype/start.mcfunction"
    content = overdraw.read_text(encoding="utf-8")
    start_gate = "execute unless entity @s[tag=sd.floor_run] run return 0\n"
    write(overdraw, start_gate + content)
    hook = BASE / "lib/on_consume.mcfunction"
    content = hook.read_text(encoding="utf-8")
    write(hook, content + '\n$execute if score #phase sd.floor matches 2 run function sweetdream_floor:combat/echo_event {mark:"$(mark)",target:"$(target)",by:"$(by)"}')
    # Keep the original encounter logic, hitboxes and moves while fitting first-floor equipment.
    boss = BASE / "boss/knight"
    for name, replacements in {
        "bind": {"Health:800f": "Health:200f", "base:800d": "base:200d"},
        "bar_create": {"max 800": "max 200"},
        "init_body": {"sdk.last_hp 800000": "sdk.last_hp 200000"},
        "dispatch": {"sdk.hp matches ..400": "sdk.hp matches ..100"},
    }.items():
        target = boss / f"{name}.mcfunction"
        body = target.read_text(encoding="utf-8")
        for old, new in replacements.items():
            assert old in body, f"Boss tuning anchor changed in {target}"
            body = body.replace(old, new, 1)
        write(target, body)
    # This upstream function otherwise fails vanilla parsing. Scope the correction to the world.
    target = BASE / "equipment/sword/crescent/stack_tick.mcfunction"
    body = target.read_text(encoding="utf-8")
    write(target, body.replace("self{ok:1b} execute store result", "self{ok:1b} store result"))
    (BASE / "equipment/bow/README.md").unlink(missing_ok=True)
    count = generate_pool()
    raw = gzip.decompress((ROOT / ".workbuddy/rogue_random_20261029/map_1900102900.dat").read_bytes())
    old = b"sweetdream:rogue_preview"
    new = b"minecraft:overworld"
    source = struct.pack(">H", len(old)) + old
    assert raw.count(source) == 1, "Unexpected source map dimension"
    raw = raw.replace(source, struct.pack(">H", len(new)) + new)
    map_data = WORLD / "data/map_1900102900.dat"
    map_data.parent.mkdir(parents=True, exist_ok=True)
    if not map_data.exists():
        map_data.write_bytes(gzip.compress(raw, mtime=0))
    js(WORK / "pool_summary.json", {"registered": count})


def resources():
    path = WORLD / "resources.zip"
    with ZipFile(path, "w", ZIP_DEFLATED, compresslevel=5) as out:
        root = ROOT / "sweetdream_rp_完整版"
        out.write(root / "pack.mcmeta", "pack.mcmeta")
        if (root / "pack.png").exists():
            out.write(root / "pack.png", "pack.png")
        for item in sorted((root / "assets").rglob("*")):
            if item.is_file():
                out.write(item, item.relative_to(root).as_posix())


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--resources", action="store_true")
    args = parser.parse_args()
    stage()
    if args.resources:
        resources()
