"""Check the first visible map, lazy event scene, and room-bound NPCs on 1.21.5."""

import gzip
import time

from architecture import LEAVES, PALE_LEAVES, PITCH, radius
from floor_upgrade import MAP_ID
from forest_floors import NEXT_MAP
from forest_junctions import PAIRS
from forest_polish import COLORS, PARCHMENT
from world import ROOT, native
from verify import PLAYER, command, phase, status, storage, tags, trigger, wait
from verify_dimension import at_floor, cells, enter, entity_count, floor_block, map_edges, visit
from verify_junctions import transfer


def check_painted_map(rooms, map_id):
    assert "Saved" in command("save-all flush")
    file = native.NATIVE/"world/data"/f"map_{map_id}.dat"
    raw = gzip.decompress(file.read_bytes())
    offset = raw.index(COLORS) + len(COLORS)
    colors = raw[offset:offset+128**2]
    assert len(colors) == 128**2 and min(colors) > 0

    def pixel(x, z):
        return colors[((z+56)//2)*128+(x+56)//2]//4

    assert len(rooms) == 16
    for x, z, _, cell in rooms.values():
        assert pixel(x-12, z-12) != PARCHMENT//4, (map_id, "missing room", cell)
        assert pixel(x, z) != PARCHMENT//4, (map_id, "missing room center", cell)
    for (a, b, axis), enabled in zip(PAIRS, map_edges()):
        if enabled == "1":
            x, z, _, _ = rooms[a]
            if axis == "east":
                x += PITCH//2
            else:
                z += PITCH//2
            assert pixel(x, z) != PARCHMENT//4, (map_id, "missing link", a, b)


def verify():
    native.WORK = ROOT/".workbuddy/rogue_forest_polish_20261123"
    native.NATIVE = native.WORK/"native"
    native.rcon.D = native.NATIVE
    if PLAYER not in command("list"):
        native.clients()
    time.sleep(1)
    if "sd.floor_run" in tags(PLAYER):
        trigger(3)
        wait(lambda: phase() == 0 and status("#rv_clean", "zx.meta") == 0, "close previous probe run")
    rooms = enter()
    check_painted_map(rooms, MAP_ID)
    assert "rg_ver: 3" in command(f"data get entity {PLAYER} Inventory[{{Slot:8b}}]")

    event = next(room for room in rooms.values() if room[2] == "event")
    x, z, _, idx = event
    state = f"floor.cells[{idx}].furnished"
    assert "Found no elements" in storage(state, "zx:rogue")
    r = radius("event")
    assert floor_block(x-r+3, 84, z-r+1, "dark_oak_log")
    assert floor_block(x-r+3, 82, z-3, "ochre_froglight")
    assert any(floor_block(x-r, 88, z, leaf) for leaf in (LEAVES, PALE_LEAVES))
    assert floor_block(x-7, 81, z-7, "air")
    assert entity_count("@e[tag=sd.floor_vendor,distance=0..]") == 0
    command(f'execute in sweetdream:floor_1_forest run summon minecraft:villager {x+5} 81 {z+5} '
            '{Tags:["sd.floor_vendor"],NoAI:1b,Invulnerable:1b}')
    command(f'execute in sweetdream:floor_1_forest run summon minecraft:interaction {x+5} 81 {z+5} '
            '{Tags:["sd.floor_vendor_hitbox"]}')
    visit(event)
    wait(lambda: "1b" in storage(state, "zx:rogue"), "event furnished")
    assert entity_count("@e[type=minecraft:villager,distance=0..]") == 0
    assert entity_count("@e[tag=sd.floor_vendor_hitbox,distance=0..]") == 0

    merchant = next(room for room in rooms.values() if room[2] == "merchant")
    visit(merchant)
    tag = f"sd.vendor_cell.{merchant[3]}"
    assert entity_count(f"@e[type=minecraft:villager,tag={tag},distance=0..]") == 1
    assert entity_count(f"@e[type=minecraft:interaction,tag={tag},distance=0..]") == 1
    for (a, b, axis), enabled in zip(PAIRS, map_edges()):
        if enabled == "1":
            x, z, kind, _ = rooms[a]
            middle = (radius(kind) + PITCH - radius(rooms[b][2]))//2
            mx, mz = (x+middle, z) if axis == "east" else (x, z+middle)
            assert floor_block(mx, 81, mz, "air") and floor_block(mx, 82, mz, "air")
    print("Forest shell, straight routes, deferred event and room-bound merchant verified.", flush=True)
    transfer(rooms)
    check_painted_map(cells(), NEXT_MAP)
    print("Both maps arrived with every room and route drawn and no transparent pixels.", flush=True)
    at_floor("function sweetdream_floor:run/exit")


if __name__ == "__main__":
    verify()
