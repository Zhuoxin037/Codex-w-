"""Stage, verify and publish the Forest world without touching the prototype save."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import shutil
import sys
import tempfile
import time
from zipfile import ZipFile, ZIP_DEFLATED, ZIP_STORED

import architecture
import cabin_clear
import cabin_corner
import cabin_lobby
import cabin_finish
import cabin_furnish
import cabin_stairs
import floor_upgrade
import forest_economy
import forest_combat
import forest_events
import forest_floors
import forest_junctions
import forest_polish
import forest_places
import forest_room_services
import forest_services
import forest_flow
import forest_balance
import forest_exploration
import lobby_expansion
import lobby_metrics
import training_portals
import training_world
import dream_gear
import dream_hub
import dream_tutorial
import forest_layout
import forest_market_layout
import forest_scene

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
WORK = ROOT / ".workbuddy/rogue_forest_dimension_20261119"
PROTOTYPE = HERE.parent / "甜梦肉鸽_首层试玩_20261119"
BASELINE = "甜梦回廊_首层试玩"
NAME = "甜梦回廊·密林"
RELEASE = HERE / f"{NAME}.zip"
sys.path.insert(0, str(PROTOTYPE))
import native  # Reuse the original vanilla 1.21.5 harness against a different port and world.

native.WORK = WORK
native.NATIVE = WORK / "native"
native.rcon.D = native.NATIVE
WORLD = native.NATIVE / "world"
ADDON = WORLD / "datapacks/zz_sweetdream_floor"
FUNCTIONS = ADDON / "data/sweetdream_floor/function"


def patch(path, changes):
    lines = path.read_text(encoding="utf-8")
    for old, new in changes:
        if old not in lines:
            raise ValueError(f"Missing source line in {path}: {old}")
        lines = lines.replace(old, new)
    path.write_text(lines, encoding="utf-8")


def prepare():
    architecture.main()
    WORLD.mkdir(parents=True, exist_ok=True)
    if not (WORK / "baseline.json").exists():
        trusted = PROTOTYPE / f"{BASELINE}.zip"
        with ZipFile(trusted) as seed:
            for item in seed.infolist():
                path = Path(item.filename)
                if path.parts[0] != BASELINE or ".." in path.parts:
                    raise ValueError(f"Unexpected prototype archive entry: {item.filename}")
                rel = Path(*path.parts[1:])
                if item.is_dir() or not rel.parts:
                    continue
                if rel.parts[0] == "datapacks" or rel.as_posix() in {"resources.zip", "data/map_1900102900.dat"}:
                    dest = WORLD / rel
                    dest.parent.mkdir(parents=True, exist_ok=True)
                    dest.write_bytes(seed.read(item))
        (WORK / "baseline.json").write_text(json.dumps({
            "base": BASELINE, "sha256": digest(trusted),
        }, ensure_ascii=False, indent=2), encoding="utf-8")
    # Reload pristine mechanics and integrate the nature-themed gates and scene text.
    shutil.copytree(PROTOTYPE / "floor_pack", ADDON, dirs_exist_ok=True)
    shutil.copytree(HERE / "floor_pack", ADDON, dirs_exist_ok=True)
    patch(FUNCTIONS / "lobby/build.mcfunction", [
        ("-112 32 -32 64", "-120 16 -24 79")
    ])
    patch(FUNCTIONS / "lobby/build_loaded.mcfunction", [
        ("-106 90 48", "-117 90 22"), ("-36 90 48", "-27 90 75"),
        ("-112 32 -32 64", "-120 16 -24 79")
    ])
    patch(FUNCTIONS / "lobby/menu.mcfunction", [
        ("选职业开始单人试做层。", "选职业进入第一层「密林」。"),
    ])
    patch(FUNCTIONS / "run/start.mcfunction", [
        ("房间编排中 · 地图正在成形", "穿过林雾，寻找前路"),
        ('"入 梦","color":"aqua"', '"入 梦","color":"dark_green"'),
        ("data modify storage sweetdream_floor:run rooms set value []",
         "data modify storage sweetdream_floor:run rooms set value []\ndata remove storage sweetdream_floor:run encounter"),
        ("scoreboard players set @s zx.j_f_given 0", "scoreboard players set @s zx.j_f_given 3"),
    ])
    patch(FUNCTIONS / "run/loading.mcfunction", [
        ("正在编排房间与连廊…", "密林正在成形…"),
        ("正在绘制楼层图…", "正在记录林间小径…"),
    ])
    patch(FUNCTIONS / "run/arrive.mcfunction", [
        ("探索 · 构筑 · 挑战坠梦骑士", "循着林间灯火，探索八间新房"),
        ('"首层 · 梦核回廊","color":"aqua"', '"第一层 · 密林","color":"green"'),
        ("minecraft:block.amethyst_block.chime", "minecraft:block.azalea_leaves.step"),
        ("setblock 6 81 54", f"setblock 6 81 {architecture.ENTRY_Z+6}"),
        ("scoreboard players set #ready sd.floor 1",
         "scoreboard players set #ready sd.floor 1\ntag @s add sd.floor_hud\nfunction sweetdream:equipment/tool/look/cache"),
    ])
    threshold = FUNCTIONS / "room/doors/threshold.mcfunction"
    threshold.write_text(
        '$execute if score #door_closed sd.floor matches 0 run return run function sweetdream_floor:room/doors/open_visual {x:$(x),z:$(z)}\n'
        'execute if block ~ ~ ~ minecraft:barrier run return 0\n'
        '$execute positioned ~-$(x) ~ ~-$(z) if entity @s[dx=$(width),dy=4,dz=$(depth)] run function sweetdream_floor:room/return_to_explored\n'
        '$function sweetdream_floor:room/doors/close_visual {x:$(x),z:$(z),sx:$(sx),sz:$(sz),axis:"$(axis)"}\n',
        encoding="utf-8",
    )
    patch(FUNCTIONS / "room/doors/update.mcfunction", [
        ("The corridor carves a quartz threshold into the deepslate perimeter only at a connected doorway.",
         "Mossy stone brick thresholds occur only at connected corridor mouths."),
        ("minecraft:smooth_quartz", "minecraft:mossy_stone_bricks"),
        ("{x:0,z:2,width:0,depth:4}", '{x:0,z:3,width:0,depth:6,sx:1,sz:7,axis:"z"}'),
        ("{x:2,z:0,width:4,depth:0}", '{x:3,z:0,width:6,depth:0,sx:7,sz:1,axis:"x"}'),
    ])
    patch(FUNCTIONS / "reward/god_show.mcfunction", [("首层通关", "密林通关")])
    patch(FUNCTIONS / "reward/god.mcfunction", [("试做层已通关。", "第一层「密林」已通关。")])
    patch(FUNCTIONS / "load.mcfunction", [
        ("function sweetdream_floor:pool/load",
         "execute unless data storage sweetdream_floor:run {dimension_layout:1b} run function sweetdream_floor:run/migrate_dimension\n"
         "team add sd.floor_vendor\nteam modify sd.floor_vendor collisionRule never\nfunction sweetdream_floor:pool/load"),
    ])
    patch(FUNCTIONS / "tick.mcfunction", [
        ("scoreboard players enable @a sd.floor_cmd",
         "scoreboard players enable @a sd.floor_cmd\neffect give @a[tag=sd.floor_seen] minecraft:saturation 1 0 true\n"
         f"execute if score #phase sd.floor matches 1.. in {floor_upgrade.DIM} run function sweetdream_floor:room/doors/tick"),
    ])
    patch(FUNCTIONS / "run/player_tick.mcfunction", [
        ("execute unless dimension minecraft:overworld run return run function sweetdream_floor:run/death\n",""),
        ("execute unless entity @s[tag=zx.rg_active] run return run function sweetdream_floor:run/exit",
         "execute unless entity @s[tag=zx.rg_active] run return run function sweetdream_floor:run/exit\n"
         f"execute unless dimension {floor_upgrade.DIM} run return 0"),
    ])
    patch(FUNCTIONS / "run/death.mcfunction", [
        ("execute if entity @s[x=-68,y=88,z=34,dx=30,dy=12,dz=28] run function sweetdream_floor:run/exit",
         "execute unless entity @s[nbt={Health:0.0f}] run function sweetdream_floor:run/exit"),
    ])
    for name in ("run/exit","run/stale"):
        patch(FUNCTIONS / (name+".mcfunction"), [
            ("tag @s remove sd.floor_run","function sweetdream_floor:run/clear_mirror\ntag @s remove sd.floor_run"),
            ("execute at @s run function sweetdream_floor:run/recycle_weapons",
             "execute at @s run function sweetdream_floor:run/recycle_kit"),
        ])
    patch(FUNCTIONS / "run/orphan.mcfunction", [
        ("function sweetdream_floor:combat/clean",
         f"execute in {floor_upgrade.DIM} as @e[type=minecraft:block_display,tag=sd.floor_gate,distance=0..] run function sweetdream_floor:room/doors/discard\n"
         f"execute in {floor_upgrade.DIM} run kill @e[tag=sd.floor_vendor,distance=0..]\n"
         f"execute in {floor_upgrade.DIM} run kill @e[tag=sd.floor_vendor_hitbox,distance=0..]\n"
         "function sweetdream_floor:combat/clean\ndata remove storage sweetdream_floor:run encounter"),
    ])
    patch(FUNCTIONS / "combat/clean.mcfunction", [("minecraft:overworld",floor_upgrade.DIM)])
    patch(FUNCTIONS / "combat/tick.mcfunction", [
        ("function sweetdream_floor:combat/boundary with storage sweetdream_floor:run current\n",""),
    ])
    patch(FUNCTIONS / "combat/begin.mcfunction", [
        ("scoreboard players set #door_closed sd.floor 1\nfunction sweetdream_floor:room/doors/update with storage sweetdream_floor:run current",
         "execute unless data storage sweetdream_floor:run encounter run function sweetdream_floor:room/lock"),
    ])
    patch(FUNCTIONS / "combat/win.mcfunction", [
        ("function sweetdream_floor:combat/open_doors",
         "function sweetdream_floor:combat/open_doors\ndata remove storage sweetdream_floor:run encounter"),
    ])
    patch(FUNCTIONS / "combat/boss_abort.mcfunction", [
        ("function sweetdream_floor:combat/open_doors\n",""),
    ])
    patch(FUNCTIONS / "room/admit.mcfunction", [
        ('title @s actionbar [{"text":"剩余探索 ","color":"aqua"},{"score":{"name":"#budget","objective":"sd.floor"}},{"text":"/8","color":"gray"}]\n',""),
    ])
    patch(FUNCTIONS / "room/teleport_cell.mcfunction", [
        ("4.5 81 48.5", f"4.5 81 {architecture.ENTRY_Z}.5"),
    ])
    patch(FUNCTIONS / "run/boss_shortcut.mcfunction", [
        ("execute if score #budget sd.floor matches 1.. run return 0",
         'execute if data storage sweetdream_floor:run encounter run return run tellraw @s {"text":"先打完这间房的战斗。","color":"yellow"}\n'
         "execute if score #budget sd.floor matches 1.. run return 0"),
    ])
    patch(FUNCTIONS / "room/status.mcfunction", [
        ("execute if score #budget sd.floor matches 0 run tellraw",
         "execute if score #budget sd.floor matches 0 unless data storage sweetdream_floor:run encounter run tellraw"),
    ])
    patch(FUNCTIONS / "lobby/player_tick.mcfunction", [
        ("execute unless entity @s[tag=sd.floor_lobby_weapons_clean,tag=!sd.floor_kit] run function sweetdream_floor:run/recycle_weapons",
         "execute unless entity @s[tag=sd.floor_kit_clean,tag=!sd.floor_kit] run function sweetdream_floor:run/recycle_legacy_kit"),
    ])
    patch(FUNCTIONS / "run/starter.mcfunction", [
        ("give @s minecraft:cooked_beef 12\n",""),
        ("function sweetdream:equipment/tool/look/give\n",""),
        ("function sweetdream:equipment/armor/intravenous_pump/give\n",""),
        ("matches 1 run function sweetdream:equipment/staff/cage_day/give",
         "matches 1 run function sweetdream:equipment/staff/mana_crystal/give"),
        ("matches 1 run function sweetdream:equipment/sword/tidemark/give",
         "matches 1 run function sweetdream:equipment/tool/grimoire/give"),
        ("matches 4 run function sweetdream:equipment/sword/backflow_tide/give",
         "matches 4 run function sweetdream:equipment/staff/self_mind/give"),
    ])
    potion = "function sweetdream_floor:room/service/ward_potion"
    for name in ("room/service/supply","room/event/resolve_traveler","reward/god"):
        patch(FUNCTIONS / (name+".mcfunction"), [("give @s minecraft:golden_apple 2",potion)])
    patch(FUNCTIONS / "room/service/supply.mcfunction", [("give @s minecraft:cooked_beef 8\n","")])
    patch(FUNCTIONS / "room/event/traveler.mcfunction", [
        ("旧背囊挂在墙上。夹层里压着纸条：带上你路上用得着的。","树根旁的背囊仍扣着铜扣。夹层里压着一张纸条。"),
        ("2 颗金苹果","2 瓶护命药剂"),
    ])
    patch(FUNCTIONS / "reward/god_show.mcfunction", [("两颗金苹果","两瓶护命药剂")])
    floor_upgrade.style_menus(FUNCTIONS)
    visit = ADDON / "data/sweetdream/function/rogue/map/visit_pick.mcfunction"
    floor_upgrade.write(visit, floor_upgrade.text(visit) +
        '\n$execute if entity @s[tag=sd.floor_run] if score #phase sd.floor matches 1..3 '
        'if score @s zx.rg_room matches $(cell) unless data storage sweetdream_floor:run encounter '
        'unless data storage sweetdream_floor:run rooms[{cell:$(cell)}] '
        'run function sweetdream_floor:room/check_lock with storage zx:rogue floor.cells[$(cell)]')
    floor_upgrade.stage(WORLD,ADDON)
    bitmap = WORLD / "data/map_1900102900.dat"
    map_data = floor_upgrade.map_dimension(gzip.decompress(bitmap.read_bytes()))
    bitmap.with_name(f"map_{floor_upgrade.MAP_ID}.dat").write_bytes(gzip.compress(map_data,mtime=0))

    # The floor is already force-loaded at this stage. Run landscape after corridors so
    # all content is visible on arrival, while keeping the reusable topology unchanged.
    generation = Path("data/sweetdream/function/rogue/gen/build_links.mcfunction")
    source = (WORLD / "datapacks/sweetdream" / generation).read_text(encoding="utf-8")
    dest = ADDON / generation
    dest.parent.mkdir(parents=True, exist_ok=True)
    source = source.replace("data modify storage zx:rogue built set value 1b",
                            "function sweetdream_floor:forest/landscape\n"
                            "function sweetdream_floor:forest/understory\n"
                            "execute unless data storage sweetdream_floor:run {forest_biome:1b} run function sweetdream_floor:forest/biome\n"
                            "data modify storage zx:rogue built set value 1b")
    dest.write_text(source, encoding="utf-8")
    cabin_lobby.stage(ADDON)
    cabin_finish.stage(ADDON)
    cabin_furnish.stage(ADDON)
    cabin_clear.stage(ADDON)
    cabin_stairs.stage(ADDON)
    cabin_stairs.stage_railing(ADDON)
    cabin_corner.stage(ADDON)
    forest_economy.stage(WORLD)
    forest_market_layout.stage(WORLD)
    forest_combat.stage(WORLD)
    forest_events.stage(WORLD)
    forest_layout.stage(WORLD)
    forest_scene.stage(WORLD)
    forest_floors.stage(WORLD)
    forest_junctions.stage(WORLD)
    forest_polish.stage(WORLD)
    forest_places.stage(WORLD)
    forest_services.stage(WORLD)
    forest_room_services.stage(WORLD)
    lobby_expansion.stage(WORLD)
    lobby_metrics.stage(WORLD)
    training_world.stage(WORLD)
    training_portals.stage(WORLD)
    dream_hub.stage(WORLD)
    dream_tutorial.stage(WORLD)
    dream_gear.stage(WORLD)
    forest_flow.stage(WORLD)
    forest_balance.stage(WORLD)
    forest_exploration.stage(WORLD)
    forest_services.remove_echo(WORLD)
    print(f"Staged {len(list(ADDON.rglob('*.mcfunction')))} addon functions")


def digest(path):
    with path.open("rb") as file:
        return hashlib.file_digest(file, "sha256").hexdigest()


def snapshot():
    for _ in range(40):
        if "1b" in native.c("data get storage sweetdream_floor:run cabin_layout"):
            break
        time.sleep(.25)
    else:
        raise RuntimeError("The lobby did not finish building")
    assert native.c("time query daytime").rstrip().endswith("9500")
    assert native.c("list").startswith("There are 0 of")
    for x, y, z, block in [
        (252,75,20,"podzol"),
        (257,77,15,"waxed_oxidized_cut_copper"),
        (266,77,2,"amethyst_block"),
        (-92,89,48,"blackstone"),
        (-73,101,48,"tuff_bricks"),
    ]:
        assert "passed" in native.c(f"execute if block {x} {y} {z} minecraft:{block}").lower(), (x,y,z,block)
    native.c("save-all flush")
    snap = WORK / "starter"
    assert not snap.exists(), f"The clean starter is already stored at {snap}"
    snap.mkdir()
    for name in ("level.dat", "data", "region", "entities", "poi"):
        src = WORLD / name
        if src.is_dir():
            shutil.copytree(src, snap / name)
        elif src.is_file():
            shutil.copy2(src, snap / name)
    print("Captured the pristine lobby before any player joined")


def pack():
    with tempfile.TemporaryDirectory(prefix="release_", dir=WORK) as scratch:
        folder = Path(scratch) / NAME
        shutil.copytree(WORK / "starter", folder)
        shutil.copytree(WORLD / "datapacks", folder / "datapacks")
        shutil.copy2(WORLD / "resources.zip", folder / "resources.zip")
        level = folder / "level.dat"
        level.write_bytes(dream_hub.rename_level(level.read_bytes()))
        interim = Path(scratch) / RELEASE.name
        with ZipFile(interim, "w", ZIP_DEFLATED, compresslevel=4) as out:
            for file in sorted(folder.rglob("*")):
                if file.is_file():
                    method = ZIP_STORED if file.suffix in {".mca", ".zip"} else ZIP_DEFLATED
                    out.write(file, file.relative_to(folder.parent).as_posix(), compress_type=method)
        with ZipFile(interim) as out:
            assert out.testzip() is None
            assert not any("/playerdata/" in key for key in out.namelist())
            for required in ("level.dat", "resources.zip", f"data/map_{floor_upgrade.MAP_ID}.dat",
                             "datapacks/manacore-1.0.0/pack.mcmeta",
                             "datapacks/sweetdream/pack.mcmeta", "datapacks/zz_sweetdream_floor/pack.mcmeta"):
                assert f"{NAME}/{required}" in out.namelist()
        shutil.copy2(interim, RELEASE)
    print(RELEASE.name, RELEASE.stat().st_size, digest(RELEASE))


def install(parent):
    parent = parent.resolve(strict=True)
    target = parent / NAME
    if parent.name != "saves" or target.exists():
        raise ValueError("Expected a saves directory with no world of this name")
    with ZipFile(RELEASE) as archive, tempfile.TemporaryDirectory(prefix="install_", dir=WORK) as scratch:
        for key in archive.namelist():
            path = Path(key)
            if path.is_absolute() or ".." in path.parts or path.parts[0] != NAME:
                raise ValueError(f"Unexpected archive entry: {key}")
        archive.extractall(scratch)
        source = Path(scratch) / NAME
        shutil.copytree(source, target)
        files = [item for item in source.rglob("*") if item.is_file()]
        for file in files:
            assert digest(file) == digest(target / file.relative_to(source)), file
    (WORK / "installed.json").write_text(json.dumps({
        "target": str(target), "files": len(files), "zip_sha256": digest(RELEASE),
    }, ensure_ascii=False, indent=2), encoding="utf-8")
    print(target, len(files))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=("prepare", "start", "snapshot", "pack", "install", "cmd"))
    parser.add_argument("value", nargs="?")
    args = parser.parse_args()
    if args.action == "start":
        native.start()
    elif args.action == "install":
        install(Path(args.value))
    elif args.action == "cmd":
        print(native.c(args.value))
    else:
        globals()[args.action]()
