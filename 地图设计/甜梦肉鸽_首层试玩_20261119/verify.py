"""Exercise the standalone map against vanilla 1.21.5 with two private players."""
from pathlib import Path
import json
import re
import shutil
import time
from native import c, clients, NATIVE, WORK

PLAYER = "DuskProbe"
OTHER = "OtherProbe"
WORLD = NATIVE / "world"
LOG = []
CHECKS = []


def command(cmd):
    reply = c(cmd)
    LOG.append((cmd, reply))
    return reply


def check(label, condition, detail=""):
    CHECKS.append({"case": label, "pass": bool(condition), "detail": detail})
    (WORK / "native_checks.json").write_text(json.dumps(CHECKS, ensure_ascii=False, indent=2), encoding="utf-8")
    (WORK / "native_commands.json").write_text(json.dumps(LOG, ensure_ascii=False, indent=2), encoding="utf-8")
    print(("PASS " if condition else "FAIL ") + label, flush=True)
    assert condition, (label, detail)


def status(who, obj="sd.floor"):
    reply = command(f"scoreboard players get {who} {obj}")
    found = re.search(r"has (-?\d+)", reply)
    return int(found[1]) if found else None


def phase():
    return status("#phase")


def storage(path, name="sweetdream_floor:run"):
    return command(f"data get storage {name} {path}")


def trigger(number, player=PLAYER):
    reply = command(f"execute as {player} at @s run trigger sd.floor_cmd set {number}")
    if "cannot" in reply.lower():
        raise AssertionError(reply)


def wait(test, label, timeout=20):
    end = time.monotonic() + timeout
    while time.monotonic() < end:
        if test():
            return
        time.sleep(0.15)
    check(f"wait for {label}", False, LOG[-8:])


def at(player, function):
    return command(f"execute as {player} at @s run function {function}")


def tags(player):
    return command("data get entity " + player + " Tags")


def scan():
    result = []
    for i in range(25):
        line = storage(f"floor.cells[{i}]", "zx:rogue")
        fields = re.search(r'\bkind: "(\w+)"', line)
        if "present: 1b" in line and fields:
            result.append(((i % 5) * 24, (i // 5) * 24, fields[1], i))
    return result


def goto(record, player=PLAYER):
    x, z, _, index = record
    command(f"tp {player} {x + .5} 81 {z + .5} 0 0")
    wait(lambda: status(player, "zx.rg_room") == index, f"room {index}")


def door_positions(record, edges):
    x, z, kind, index = record
    row, column = divmod(index, 5)
    radius = {"boss": 12, "elite": 10}.get(kind, 9)
    doors = []
    if column and edges[row * 4 + column - 1] == "1":
        doors.append((x - radius, z))
    if column < 4 and edges[row * 4 + column] == "1":
        doors.append((x + radius, z))
    if row and edges[20 + index - 5] == "1":
        doors.append((x, z - radius))
    if row < 4 and edges[20 + index] == "1":
        doors.append((x, z + radius))
    return doors


def block_is(x, y, z, block):
    return "passed" in command(f"execute if block {x} {y} {z} minecraft:{block}").lower()


def doors_are(doors, block):
    return bool(doors) and all(block_is(x, y, z, block) for x, z in doors for y in (81, 85))


def on_safe_aisle(room):
    x, z, _, _ = room
    position = command(f"data get entity {PLAYER} Pos")
    return f"[{x + 4.5}d, 81.0d, {z + .5}d]" in position


def starter_snapshot():
    dest = WORK / "starter"
    if (dest / "level.dat").exists():
        return
    command("save-all flush")
    for name in ["level.dat", "data", "region", "entities", "poi"]:
        item = WORLD / name
        if item.is_dir():
            shutil.copytree(item, dest / name, dirs_exist_ok=True)
        elif item.is_file():
            dest.mkdir(parents=True, exist_ok=True)
            shutil.copy2(item, dest / name)


def mob_count(tag="sd.floor_enemy"):
    reply = command(f"execute in minecraft:overworld if entity @e[tag={tag},distance=0..]")
    match = re.search(r"count: (\d+)", reply)
    return int(match[1]) if match else 0


def note_floor():
    trigger(10)
    wait(lambda: "zx.rg_active" in tags(PLAYER), "active generated floor", 55)
    return scan()


def exercise():
    check("lobby structure ready", "1b" in storage("lobby"))
    check("fresh world mode / spawn rules", "true" in command("gamerule keepInventory") and "true" in command("gamerule doImmediateRespawn"))
    starter_snapshot()
    if PLAYER not in command("list"):
        clients()
    wait(lambda: "sd.floor_seen" in tags(PLAYER), "first join")
    if "sd.floor_run" in tags(PLAYER) or "sd.floor_tutorial" in tags(PLAYER):
        trigger(3)
        wait(lambda: phase() == 0 and status("#rv_clean", "zx.meta") == 0, "reset previous probe")
    check("player spawned in waiting lobby", "-48.5" in command(f"data get entity {PLAYER} Pos"))
    trigger(2)
    wait(lambda: "sd.floor_tutorial" in tags(PLAYER), "tutorial")
    check("tutorial physical room", "-101.5" in command(f"data get entity {PLAYER} Pos"))
    wait(lambda: "4b" in storage("demonstration"), "world-space tutorial installed")
    check("tutorial lectern has its book", "passed" in command("execute if block -100 90 46 minecraft:lectern[has_book=true]").lower())
    check("old practice button is gone", "passed" in command("execute if block -103 90 50 minecraft:air").lower())
    trigger(3)
    wait(lambda: "sd.floor_tutorial" not in tags(PLAYER), "leave tutorial")
    rooms = note_floor()
    check("16 generated rooms with all services", len(rooms) == 16 and len({x[2] for x in rooms}) == 12, rooms)
    edges = re.findall(r"([01])b", storage("floor.edges", "zx:rogue"))
    check("ninth slot real map", "1900102900" in command(f'data get entity {PLAYER} Inventory[{{Slot:8b}}].components."minecraft:map_id"'))
    trigger(12, OTHER)
    time.sleep(.4)
    check("waiting lobby remains available, solo floor is locked", "sd.floor_run" not in tags(OTHER))
    boss = next(x for x in rooms if x[2] == "boss")
    boss_doors = door_positions(boss, edges)
    goto(boss)
    check("the entrance and boss room are free to enter", status("#budget") == 8)
    trigger(20)
    wait(lambda: phase() == 2 and mob_count("sd.kn.body") == 1, "boss starts before any wins")
    check("boss opens on arrival without a seal gate", status("#budget") == 8)
    check("boss battle closes its connected thresholds", doors_are(boss_doors, "magenta_stained_glass"))
    goto(next(x for x in rooms if x[2] == "entry"))
    wait(lambda: phase() == 1, "leave the early boss battle")
    check("retreat reopens the boss thresholds", doors_are(boss_doors, "air"))
    rooms_by_kind = {kind: [x for x in rooms if x[2] == kind] for kind in {x[2] for x in rooms}}
    event = rooms_by_kind["event"][0]
    # The main route uses the traveller fixture to fund its forge purchase.
    command(f"data modify storage zx:rogue floor.cells[{event[3]}].variant set value 0")
    goto(event)
    check("first visit to an event also spends exploration", status("#budget") == 7)
    command("scoreboard players set #budget sd.floor 4")
    command("data remove storage sweetdream_floor:run exploration")
    wait(lambda: status("#budget") == 7 and "1b" in storage("exploration"), "migrate an existing floor's mapped rooms")
    check("a pre-update floor gets a budget based on its mapped rooms", True)
    trigger(20)
    wait(lambda: status("#lumen") == 2, "event proceeds")
    goto(rooms_by_kind["forge"][0])
    trigger(20)
    wait(lambda: status("#lumen") == 1, "pay forge")
    stone = command(f'clear {PLAYER} *[minecraft:custom_data~{{zx:["up_mana_up_a"]}}] 0')
    check("forge issues native upgrade stone", "Found" in stone, stone)
    goto(rooms_by_kind["astrology"][0])
    trigger(20)
    wait(lambda: status("#boon") == 1, "astrology boon")
    goto(rooms_by_kind["rental"][0])
    trigger(20)
    wait(lambda: phase() == 3, "rental gear options")
    opts = storage("offers")
    check("three distinct usable label options", len(re.findall(r'\btag: "\w+"', opts)) == 3, opts)
    command("scoreboard players set #unused sd.floor 0")
    trigger(30)
    wait(lambda: phase() == 1, "reward claim")

    combat = rooms_by_kind["combat"]
    goto(combat[0])
    visit_budget = status("#budget")
    # Test an actual mark and consume on an active enemy before removing the room wave.
    trigger(21)
    wait(lambda: phase() == 2, "engage first battle")
    check("wager spawns reinforced wave", mob_count() >= 5)
    combat_doors = door_positions(combat[0], edges)
    check("normal combat closes the real room exits", doors_are(combat_doors, "magenta_stained_glass"))
    command("effect give DuskProbe minecraft:resistance 20 4 true")
    for name in ("yuanhai", "liuhuo", "dream"):
        # This uses the real attachment + consume entry points, with the floor's living wave as victim.
        at(PLAYER, f'sweetdream:tag/mark {{target:"@e[tag=sd.floor_enemy,sort=nearest,limit=1]",mark:"{name}"}}')
        command(f'data modify storage zx:work a set value {{target:"@e[tag=sd.floor_enemy,sort=nearest,limit=1]",mark:"{name}"}}')
        at(PLAYER, "sweetdream:lib/mark_consume")
    wait(lambda: status("#echo_combo") == 1, "three real status consumes")
    check("native consumption advances floor echo", status("#echo_total") >= 3)
    command("kill @e[tag=sd.floor_enemy,distance=0..]")
    wait(lambda: phase() == 3, "first normal win rolls an equipment offer")
    check("victory opens the combat doors before claiming the reward", doors_are(combat_doors, "air"))
    check("wager pays extra dream fragments and does not spend more exploration",
          status("#lumen") == 4 and status("#budget") == visit_budget)
    check("wager gives a battle offer on the first victory", "1b" in storage("battle_draw"))
    trigger(31)
    wait(lambda: phase() == 1, "wager claim")
    goto(rooms_by_kind["merchant"][0])
    balance = status("#lumen")
    trigger(21)
    wait(lambda: status("#lumen") == balance - 1, "merchant purchase")
    check("merchant charges currency and provides supplies", "Found" in command(f"clear {PLAYER} minecraft:golden_apple 0"))
    goto(rooms_by_kind["safe"][0])
    command(f"effect clear {PLAYER} minecraft:resistance")
    command(f"damage {PLAYER} 4 minecraft:out_of_world")
    trigger(20)
    time.sleep(.3)
    max_health = float(command(f"attribute {PLAYER} minecraft:max_health get").rsplit(" ", 1)[1])
    health = float(command(f"data get entity {PLAYER} Health").rsplit(": ", 1)[1].rstrip("f"))
    check("rest room restores life", health == max_health)
    command(f"effect give {PLAYER} minecraft:resistance 20 4 true")
    # Make additional practice weapons available for the three-weapon gate, then clear those temporary test items.
    for _ in range(4):
        at(PLAYER, "sweetdream:equipment/sword/tidemark/give")
    goto(combat[1])
    trigger(20)
    time.sleep(.4)
    check("fourth weapon blocks entry", phase() == 1 and status("#weapons") >= 4)
    trigger(22)
    time.sleep(.4)
    x, z, _, _ = combat[1]
    check("room storage chest is available", "passed" in command(f"execute if block {x+6} 81 {z+6} minecraft:ender_chest").lower())
    for category in ("sword", "axe", "bow", "staff"):
        command(f'clear {PLAYER} *[minecraft:custom_data~{{zx:["{category}"]}}]')
    at(PLAYER, "sweetdream:equipment/sword/tidemark/give")
    trigger(20)
    wait(lambda: phase() == 2, "normal battle")
    command("kill @e[tag=sd.floor_enemy,distance=0..]")
    wait(lambda: phase() == 3, "another normal win immediately rolls an equipment offer")
    check("the last admitted room can be fought at zero exploration", status("#budget") == 0)
    trigger(30)
    wait(lambda: phase() == 1, "normal claim")

    elite = rooms_by_kind["elite"][0]
    ex, ez, _, elite_idx = elite
    check("all unexplored service and battle thresholds close at zero",
          all(doors_are(door_positions(room, edges), "magenta_stained_glass")
              for room in rooms if room[2] not in ("entry", "boss")
              and "visited: 0b" in storage(f"floor.cells[{room[3]}]", "zx:rogue")))
    check("visited rooms and the boss thresholds stay open at zero",
          all(doors_are(door_positions(room, edges), "air")
              for room in rooms if room[2] in ("entry", "boss")
              or "visited: 1b" in storage(f"floor.cells[{room[3]}]", "zx:rogue")))
    goto(event)
    event_x, event_z, _, event_idx = event
    check("the old return point is actually obstructed", block_is(event_x, 81, event_z, "chiseled_stone_bricks"))
    command("data remove storage sweetdream_floor:run exploration_doors")
    wait(lambda: on_safe_aisle(event), "recover a player trapped at the old return point")
    check("the exhausted save recovers to a clear aisle",
          block_is(event_x + 4, 81, event_z, "air") and block_is(event_x + 4, 82, event_z, "air"))
    command(f"tp {PLAYER} {ex + .5} 81 {ez + .5}")
    wait(lambda: on_safe_aisle(event), "recover after forced movement into an unexplored room")
    unseen = command(f"data get storage zx:rogue floor.cells[{elite_idx}].visited")
    check("exhaustion returns the player to the last explored room without marking the blocked room",
          status(PLAYER, "zx.rg_room") == event_idx and "1b" not in unseen, unseen)
    goto(event)
    check("re-entering an explored room at zero is free", status("#budget") == 0)
    trigger(24)
    wait(lambda: status(PLAYER, "zx.rg_room") == boss[3], "exhaustion shortcut to boss")
    check("exhaustion still offers a working boss route", status("#budget") == 0)

    # Continue covering the elite and black-market branches after the real cap check.
    command("scoreboard players set #budget sd.floor 2")
    goto(elite)
    trigger(20)
    wait(lambda: phase() == 2, "elite battle")
    command("kill @e[tag=sd.floor_enemy,distance=0..]")
    wait(lambda: phase() == 3, "elite equipment offer")
    roll = status("#quality")
    expected = next((tier for tier, limit in enumerate((3000, 6000, 9200), 1) if roll <= limit), 4)
    check("elite pays at once using elite thresholds", "1b" in storage("battle_draw") and storage("exact_tier").endswith(f": {expected}"))
    trigger(31)
    wait(lambda: phase() == 1, "elite claim")
    goto(rooms_by_kind["blackmarket"][0])
    # Select a real copy of 潮痕 so we can validate the correct of/id is chosen.
    slot = command(f'data get entity {PLAYER} Inventory[{{components:{{"minecraft:custom_data":{{zx:["tidemark","sword","itemreplace"]}}}}}}].Slot')
    match = re.search(r": (\d+)b$", slot)
    if match:
        index = int(match[1])
        slot_name = f"hotbar.{index}" if index < 9 else f"inventory.{index - 9}"
        selected = int(command(f"data get entity {PLAYER} SelectedItemSlot").rsplit(": ", 1)[1])
        if index != selected:
            command(f"item replace entity {PLAYER} weapon.mainhand from entity {PLAYER} {slot_name}")
            command(f"item replace entity {PLAYER} {slot_name} with minecraft:air")
    trigger(20)
    time.sleep(.3)
    check("black market issues equipment-matched overlimit stone", "Found" in command(f'clear {PLAYER} *[minecraft:custom_data~{{zx:["ol_tidemark"]}}] 0'), LOG[-4:])

    goto(boss)
    trigger(20)
    wait(lambda: phase() == 2 and mob_count("sd.kn.body") == 1, "native Knight spawn")
    hp = command("data get entity @e[tag=sd.kn.body,limit=1] Health")
    check("native 200 HP knight appears", "200.0f" in hp, hp)
    command("damage @e[tag=sd.kn.body,limit=1] 110 minecraft:out_of_world")
    wait(lambda: status("@e[tag=sd.kn.body,limit=1]", "sdk.phase") == 2, "knight phase 2")
    check("Knight activates phase 2 at the trial threshold", True)
    command("kill @e[tag=sd.kn.body,distance=0..]")
    wait(lambda: phase() == 4, "god talent after knight defeat")
    check("boss victory opens its doors", doors_are(boss_doors, "air"))
    trigger(41)
    wait(lambda: phase() == 5, "god talent claim")
    command(f'item replace entity {PLAYER} enderchest.26 with minecraft:crossbow[minecraft:custom_data={{zx:["bow"]}}]')
    trigger(3)
    wait(lambda: phase() == 0 and "sd.floor_run" not in tags(PLAYER), "leave cleared floor")
    check("returns to lobby after winning", "-48.5" in command(f"data get entity {PLAYER} Pos"))
    check("returning from a clear recycles reserved and carried weapons",
          "passed" in command(f"execute unless items entity {PLAYER} enderchest.26 *").lower()
          and "Found" not in command(f'clear {PLAYER} *[minecraft:custom_data~{{zx:["sword"]}}] 0'))
    wait(lambda: status("#rv_clean", "zx.meta") == 0, "clean previous floor")
    rooms2 = note_floor()
    check("replaying rolls another random layout", rooms2 != rooms)
    edges2 = re.findall(r"([01])b", storage("floor.edges", "zx:rogue"))
    check("doors from the previous run do not carry over",
          all(doors_are(door_positions(room, edges2), "air") for room in rooms2))
    command(f'item replace entity {PLAYER} weapon.offhand with minecraft:recovery_compass[minecraft:custom_data={{zx:["staff"]}}]')
    command(f'item replace entity {PLAYER} enderchest.0 with minecraft:iron_axe[minecraft:custom_data={{zx:["axe"]}}]')
    command(f"kill {PLAYER}")
    wait(lambda: phase() == 0 and "sd.floor_run" not in tags(PLAYER), "death returns to lobby")
    check("death path releases world state", "zx.rg_active" not in tags(PLAYER))
    check("death recycles inventory, offhand, and reserved weapons",
          "passed" in command(f"execute unless items entity {PLAYER} enderchest.0 *").lower()
          and "passed" in command(f"execute unless items entity {PLAYER} weapon.offhand *").lower()
          and "Found" not in command(f'clear {PLAYER} *[minecraft:custom_data~{{zx:["sword"]}}] 0'))
    (WORK / "native_checks.json").write_text(json.dumps(CHECKS, ensure_ascii=False, indent=2), encoding="utf-8")

if __name__ == "__main__":
    exercise()
