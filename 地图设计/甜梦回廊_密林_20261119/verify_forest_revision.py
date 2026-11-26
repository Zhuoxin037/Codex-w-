"""Verify room services using real players and the generated Forest."""

import hashlib
import re
import time
from uuid import UUID

from world import ROOT, native
import verify
from verify import OTHER, PLAYER, phase, status, storage, tags, trigger, wait
from verify_dimension import at_floor, enter, floor_block, move, visit
from floor_upgrade import DIM
from cabin_lobby import CAMP


def set_harness():
    native.WORK = ROOT / ".workbuddy/rogue_forest_revision_20261123"
    native.NATIVE = native.WORK / "verified"
    native.rcon.D = native.NATIVE
    verify.WORK = native.WORK


def c(row):
    return native.c(row)


def earned(name):
    return set(re.findall(r"sd\.astro\.([a-z]+)", tags(name)))


def action(code, player=PLAYER):
    trigger(code, player)
    wait(lambda: status(player, "sd.floor_cmd") == 0, f"handle action {code}")


def enter_room(rooms, kind, fallback=None):
    room = next((row for row in rooms.values() if row[2] == kind), None)
    if room is None:
        x,z,_,cell = fallback
        room = x,z,kind,cell
    x,z,_,cell = room
    if f'"{kind}"' not in storage(f"floor.cells[{cell}].kind", "zx:rogue"):
        c(f'data modify storage zx:rogue floor.cells[{cell}].kind set value "{kind}"')
        c(f"data modify storage zx:rogue floor.cells[{cell}].visited set value 0b")
        c(f"data modify storage zx:rogue floor.cells[{cell}].furnished set value 0b")
    c("scoreboard players set #budget sd.floor 8")
    visit(room)
    return room


def health_cap(player):
    return float(c(f"attribute {player} minecraft:max_health get").rsplit(" ",1)[1])


def mana_cap(player):
    uuid = UUID(bytes=hashlib.md5(("OfflinePlayer:"+player).encode()).digest(),version=3).hex
    return float(c(f'data get storage manacore:players "{uuid}".stats.max_mana').rsplit(" ",1)[1].rstrip("d"))


def verify_main():
    set_harness()
    if PLAYER not in c("list"):
        native.clients()
    # Each run uses the existing lobby/ready path before any deterministic
    # fixtures are applied to rare rooms or drops.
    if any("sd.floor_run" in tags(player) for player in (PLAYER,OTHER)):
        for player in (PLAYER,OTHER):
            if "sd.floor_run" in tags(player):
                action(3,player)
        wait(lambda: phase()==0 and status("#rv_clean","zx.meta")==0,"exit previous probe")
    x,y,z = CAMP
    c(f"execute in minecraft:overworld run tp {OTHER} {x} {y} {z}")
    wait(lambda: "sd.floor_pad" in tags(OTHER),"teammate reaches camp")
    action(11,OTHER)
    wait(lambda: "sd.lobby_ready" in tags(OTHER),"teammate prepares")
    rooms = enter()
    wait(lambda: "sd.floor_hud" in tags(OTHER),"teammate enters this run",60)
    assert len(rooms) == 16
    event = next(row for row in rooms.values() if row[2] == "event")
    x,z,_,cell = event
    assert "Found no elements" in storage(f"floor.cells[{cell}].furnished", "zx:rogue")
    assert floor_block(x-3,82,z-3,"light[level=15]")
    c(f"data modify storage zx:rogue floor.cells[{cell}].variant set value 5")
    visit(event)
    assert floor_block(x-11,84,z-7,"dark_oak_stairs[facing=east]")
    assert floor_block(x-7,81,z-5,"air") or floor_block(x-7,81,z-5,"light")
    print("PASS The new Forest set the hidden light grid and generated the roof only after entering.", flush=True)

    astro = enter_room(rooms,"astrology")
    action(20)
    first = earned(PLAYER)
    assert len(first) == 1, first
    action(20)
    assert earned(PLAYER) == first
    assert f"{{cell: {astro[3]}}}" in storage("rooms")
    assert floor_block(astro[0]-6,82,astro[1]-6,"amethyst_block")
    c(f"execute in {DIM} run tp OtherProbe {astro[0]+4.5} 81 {astro[1]+0.5}")
    wait(lambda: status(OTHER,"zx.rg_room")==astro[3], "teammate enters astrology")
    action(20, OTHER)
    assert len(earned(OTHER)) == 1
    print("PASS Each player claimed one real, named talent independently.", flush=True)
    c("save-all flush")

    black = enter_room(rooms,"blackmarket",event)
    for i in range(5):
        stock = storage(f"black.stock[{i}]")
        assert "preview_id" in stock and f"slot: {i}" in stock, stock[:450]
        if i >= 3:
            assert re.search(r"tier: [345]", stock), stock[:160]
    before_hp = health_cap(PLAYER)
    action(100)
    assert abs(health_cap(PLAYER) - before_hp*.88) < 0.02
    action(100)
    assert abs(health_cap(PLAYER) - before_hp*.88) < 0.02
    before_mana = mana_cap(PLAYER)
    action(103)
    time.sleep(.4)
    assert abs(mana_cap(PLAYER) - before_mana*.88) < 0.08, (before_mana,mana_cap(PLAYER))
    action(111)
    assert phase()==3
    action(38)
    quality = int(storage("exact_tier").rsplit(" ",1)[1])
    assert quality >= 3 and "tag:" in storage("offers[0]")
    offer = storage("offers[0]")
    action(115)
    assert phase()==1 and 'category: "weapon"' in storage("draw_stash[0]")
    backup = next(row for row in rooms.values() if row[2] == "rental")
    enter_room(rooms, "safe", backup)
    action(21)
    assert phase()==3 and storage("offers[0]") == offer
    assert int(storage("exact_tier").rsplit(" ",1)[1])==quality
    assert "Found no elements" in storage("draw_stash[0]")
    action(30)
    assert phase()==1
    print("PASS Black market had five actual items and both payments worked. A stored weapon draw retained quality and tag choices.", flush=True)
    check_extra_rooms(rooms)
    action(3,OTHER)
    action(3)
    wait(lambda: phase()==0,"leave the run")
    assert health_cap(PLAYER) == 20 and not earned(PLAYER)
    assert status(PLAYER, "sd.bl_mana") is None
    print("PASS Exit cleared the run talents and sacrifices.", flush=True)


def check_extra_rooms(rooms):
    c("scoreboard players set #lumen sd.floor 10")
    # Use an actual compatible held item and verify its installed tier changed.
    enter_room(rooms,"forge")
    sword = 'minecraft:iron_sword[minecraft:custom_data={zx:["test","sword"],up:["breach_a"]}]'
    c(f"item replace entity {PLAYER} weapon.mainhand with {sword}")
    action(20)
    assert status("#lumen")==8
    action(21)
    assert status("#lumen")==3
    assert "breach_b" in c(f"data get entity {PLAYER} SelectedItem")
    action(21)
    assert status("#lumen")==3
    print("PASS Forge charged 2 and 5 separately and promoted the held upgrade.", flush=True)
    c(f"item replace entity {PLAYER} weapon.mainhand with air")
    enter_room(rooms, "rental")
    action(20)
    loan = '*[minecraft:custom_data~{sd_rental:1b}]'
    assert "Found 1 matching" in c(f"clear {PLAYER} {loan} 0")

    combat = enter_room(rooms,"combat")
    c(f"execute in {DIM} run tp {OTHER} {combat[0]+4.5} 81 {combat[1]+0.5}")
    action(20)
    wait(lambda: phase()==2,"start test encounter")
    at_floor("kill @e[tag=sd.floor_enemy,distance=0..]")
    at_floor("kill @e[tag=sd.mob.resin_pending,distance=0..]")
    wait(lambda: phase()==3,"end rental's first fight")
    assert "Found" not in c(f"clear {PLAYER} {loan} 0")
    action(116)
    print("PASS The borrowed item burned after the next battle and the draw could be discarded.", flush=True)

    target = next(row for row in rooms.values() if row[2] == "merchant")
    enter_room(rooms, "gamble", target)
    before = status("#lumen")
    action(20)
    assert status("#lumen") in (before-1,before+3)
    for i in range(3):
        assert "text:" in storage(f"slot_line[{i}]")
    if phase()==3:
        action(116)
    print("PASS Slot machine charged one Dream Shard and produced three reel results.", flush=True)


if __name__ == "__main__":
    verify_main()
