"""Verify the generated Forest and its inherited run lifecycle on vanilla 1.21.5."""
import re
import shutil
from world import WORK, WORLD, native
from verify import (
    PLAYER, OTHER, block_is, check, command, door_positions, doors_are,
    mob_count, note_floor, on_safe_aisle, phase, status, storage, tags, trigger, wait,
)


def cell_position(room, dx=0, z_offset=0):
    x, z, _, idx = room
    command(f"tp {PLAYER} {x + dx + .5} 81 {z + z_offset + .5} 0 0")
    wait(lambda: status(PLAYER, "zx.rg_room") == idx, f"room {idx}")


def edges():
    return re.findall(r"([01])b", storage("floor.edges", "zx:rogue"))


def count_rooms(status_id):
    return command(f'execute if data storage zx:rogue floor.cells[{{present:1b,visited:{status_id}b}}]')


def capture_build():
    command("save-all flush")
    shutil.copytree(WORLD / "region", WORK / "forest_preview/region", dirs_exist_ok=True)


def main():
    if PLAYER not in command("list"):
        native.clients()
    wait(lambda: "sd.floor_seen" in tags(PLAYER), "lobby join")
    if "sd.floor_run" in tags(PLAYER) or "sd.floor_tutorial" in tags(PLAYER):
        trigger(3)
    wait(lambda: phase() == 0 and status("#rv_clean", "zx.meta") == 0, "lobby reset")
    check("the lobby spawns players on the central aisle", "-48.5d, 90.0d, 48.5d" in command(f"data get entity {PLAYER} Pos"))
    check("the entrance pavilions and station roof were built",
          block_is(-55,89,41,"oxidized_cut_copper") and block_is(-55,89,55,"amethyst_block")
          and block_is(-60,114,48,"waxed_weathered_cut_copper"))
    check("the waiting hall has late-afternoon lighting and respawn rules", "true" in command("gamerule keepInventory")
          and command("time query daytime").endswith("9500"))
    check("the bridge roof stays behind the moon window",
          block_is(-74,97,48,"dark_prismarine") and not block_is(-72,97,48,"dark_prismarine"))
    command(f"tp {PLAYER} -55.5 90 55.5")
    wait(lambda: "sd.floor_tutorial" in tags(PLAYER), "physical amethyst pad")
    wait(lambda: "4b" in storage("demonstration"), "seven-part tutorial initialized")
    check("tutorial keeps the interactive lectern",
          block_is(-100,90,46,"lectern[has_book=true]") and block_is(-100,90,49,"polished_blackstone_button"))
    command("setblock -100 90 49 minecraft:polished_blackstone_button[face=floor,facing=east,powered=true]")
    wait(lambda: status("#edu_page") == 2, "next demonstration")
    trigger(3)
    wait(lambda: "sd.floor_tutorial" not in tags(PLAYER), "return to lobby")
    command(f"tp {PLAYER} -55.5 90 41.5")
    wait(lambda: "sd.floor_pad" in tags(PLAYER), "physical start pad")
    rooms = note_floor()
    border = edges()
    kinds = {room[2] for room in rooms}
    check("sixteen rooms with all twelve room types", len(rooms) == 16 and len(kinds) == 12, rooms)
    check("dungeon entry only starts one run at a time",
          "sd.floor_run" not in tags(OTHER) and status("#budget") == 8)
    check("a real map is still in hotbar slot 9",
          "1900102900" in command(f'data get entity {PLAYER} Inventory[{{Slot:8b}}].components."minecraft:map_id"'))
    check("forest landscape has a real dark-forest biome and moss earth",
          "passed" in command("execute if biome 0 81 48 minecraft:dark_forest").lower()
          and block_is(0,78,48,"moss_block"))
    check("arrival, room return points, and corridors are passable in the live world",
          all(block_is(x+4, y, z, "air") for x,z,_,_ in rooms for y in (81,82))
          and all(doors_are(door_positions(room, border), "air") for room in rooms))
    check("the old map topology matches the forest corridor thresholds",
          all(block_is(x,80,z,"mossy_stone_bricks") for room in rooms for x,z in door_positions(room,border)))
    check("outskirts include mature trees above the room canopies", block_is(111,85,4,"dark_oak_log"))
    unbuilt = set(range(25)) - {room[3] for room in rooms}
    check("unused cells are fully wooded without counting as rooms",
          all(block_is((cell%5)*24-3,83,(cell//5)*24+2,"dark_oak_log") for cell in unbuilt))
    capture_build()

    combat = [room for room in rooms if room[2]=="combat"]
    boss = next(room for room in rooms if room[2]=="boss")
    boss_x,boss_z,_,_ = boss
    check("the Knight arena has a broken stone gate with a clear central approach",
          block_is(boss_x-5,85,boss_z-8,"cracked_deepslate_bricks")
          and block_is(boss_x,81,boss_z-8,"air"))
    elite = next(room for room in rooms if room[2]=="elite")
    event = next(room for room in rooms if room[2]=="event")
    cell_position(combat[0],dx=4)
    trigger(21)
    wait(lambda: phase() == 2 and mob_count() >= 5, "wagered grove battle")
    check("forest combat closes only this room's entrances",
          doors_are(door_positions(combat[0], border), "green_stained_glass")
          and doors_are(door_positions(boss, border), "air"))
    command("kill @e[tag=sd.floor_enemy]")
    wait(lambda: phase() == 3, "first battle reward")
    check("the first victory pays one draw and reopens the room", "1b" in storage("battle_draw")
          and doors_are(door_positions(combat[0], border), "air"))
    trigger(30)
    wait(lambda: phase() == 1, "select battle reward")
    cell_position(elite, dx=4)
    trigger(20)
    wait(lambda: phase() == 2 and mob_count() >= 5, "elite battle")
    command("kill @e[tag=sd.floor_enemy]")
    wait(lambda: phase() == 3, "elite draw")
    roll = status("#quality")
    expected = next((tier for tier, max_roll in enumerate((3000, 6000, 9200), 1) if roll <= max_roll), 4)
    check("elite uses its separate higher rarity distribution", storage("exact_tier").endswith(f": {expected}"))
    trigger(30)
    wait(lambda: phase() == 1, "select elite reward")

    new_rooms = [r for r in rooms if r[2] not in ("entry", "boss", "elite", "event") and r != combat[0]]
    for room in new_rooms[:5]:
        cell_position(room, dx=4)
    cell_position(event, dx=4)
    check("the eighth new room exhausts the budget but remains open", status("#budget") == 0
          and doors_are(door_positions(event, border), "air"))
    wait(lambda: "1b" in storage("exploration_doors"), "close unexplored rooms")
    unpaid = new_rooms[5:]
    check("all unexplored thresholds seal while the boss stays available",
          all(doors_are(door_positions(room, border), "green_stained_glass") for room in unpaid)
          and doors_are(door_positions(boss, border), "air"))
    bx,bz,_,unseen = unpaid[0]
    command(f"tp {PLAYER} {bx+.5} 81 {bz+.5}")
    wait(lambda: on_safe_aisle(event), "safe fallback after forced movement")
    check("blocked entry falls back to the last room and spends no budget",
          status(PLAYER, "zx.rg_room") == event[3] and status("#budget") == 0
          and storage(f"floor.cells[{unseen}].visited", "zx:rogue").endswith("0b"))
    cell_position(combat[0], dx=4)
    check("revisiting costs no exploration", status("#budget") == 0)
    trigger(24)
    wait(lambda: on_safe_aisle(boss), "boss shortcut")
    trigger(20)
    wait(lambda: phase() == 2 and mob_count("sd.kn.body") == 1, "boss fight")
    check("the real Knight and its full-height arena doors are working",
          "200.0f" in command("data get entity @e[tag=sd.kn.body,limit=1] Health")
          and doors_are(door_positions(boss, border), "green_stained_glass"))
    command("damage @e[tag=sd.kn.body,limit=1] 110 minecraft:out_of_world")
    wait(lambda: status("@e[tag=sd.kn.body,limit=1]", "sdk.phase") == 2, "second Knight phase")
    command("kill @e[tag=sd.kn.body,limit=1]")
    wait(lambda: phase() == 4, "first floor clear")
    check("the forest boss reopens its exits and grants the god choice", doors_are(door_positions(boss,border),"air"))
    trigger(41)
    wait(lambda: phase() == 5, "claim god reward")
    trigger(3)
    wait(lambda: phase() == 0 and status("#rv_clean","zx.meta") == 0, "clean up first run")
    check("clearing returns to the waiting hall and recycles weapons",
          "-48.5d, 90.0d, 48.5d" in command(f"data get entity {PLAYER} Pos")
          and "Found" not in command(f'clear {PLAYER} *[minecraft:custom_data~{{zx:["sword"]}}] 0'))
    replay = note_floor()
    replay_edges = edges()
    check("replay rerolls the forest and starts with clear doors",
          replay != rooms and status("#budget") == 8
          and all(doors_are(door_positions(room,replay_edges),"air") for room in replay))
    command(f'item replace entity {PLAYER} enderchest.0 with minecraft:iron_axe[minecraft:custom_data={{zx:["axe"]}}]')
    command(f"kill {PLAYER}")
    wait(lambda: phase() == 0 and "sd.floor_run" not in tags(PLAYER), "defeat returns to lobby")
    check("defeat also recycles reserved weapons",
          "passed" in command(f"execute unless items entity {PLAYER} enderchest.0 *").lower())


if __name__ == "__main__":
    main()
