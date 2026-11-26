"""Verify the camp, dimension portal, training classification, and exact door coordinates."""

import gzip
import re

from cabin_lobby import CAMP, TUTORIAL
from dream_gear import BENCH
from dream_hub import HEALING
from dream_tutorial import DIM as STUDY
from floor_upgrade import DIM
from lobby_expansion import PREVIEW, READY, TRAINING_DIM
from lobby_metrics import ROSTER
from verify_training_portals import client, entity, move, shift, step
from world import ROOT,native
from verify import PLAYER, command, status, storage, tags, wait
from verify_lobby import action, dimension


def verify():
    work=ROOT/".workbuddy/rogue_dream_hub_20261123"
    native.WORK=work
    native.NATIVE=work/"final"
    native.rcon.D=native.NATIVE
    proc,key=client(work,capture_chat=True)
    try:
        check_camp(key)
        check_study(key)
        check_training(key)
        check_doors()
    finally:
        proc.terminate()
        proc.wait(timeout=5)


def chat():
    return (native.WORK/"shift-client.log").read_text(encoding="utf8")


def health():
    return float(command(f"data get entity {PLAYER} Health").rsplit(" ",1)[1].rstrip("f"))


def check_camp(key):
    wait(lambda:"sd.floor_seen" in tags(PLAYER),"lobby joined")
    raw=gzip.decompress((native.NATIVE/"world/level.dat").read_bytes())
    assert b"\x08\x00\x09LevelName\x00\x06"+b'\xe5\x9d\xa0\xe6\xa2\xa6' in raw
    wait(lambda:"1b" in storage("tutorial_ready"),"tutorial dimension built",60)
    wait(lambda:HEALING in tags(PLAYER),"lobby regeneration applied")
    command(f"gamemode adventure {PLAYER}")
    start=health()
    command(f"damage {PLAYER} 6 minecraft:magic")
    wait(lambda:start-6<health()<start,"lobby health recovers")
    prompt="选择职业进入准备状态"
    initial=chat().count(prompt)
    for _ in range(2):
        move(PLAYER,CAMP,"minecraft:overworld")
        step(4)
        move(PLAYER,(252.5,76,20.5),"minecraft:overworld")
    move(PLAYER,CAMP,"minecraft:overworld")
    step()
    assert chat().count(prompt)==initial
    shift(key,True)
    wait(lambda:chat().count(prompt)==initial+1,"one class prompt on Shift")
    step(20)
    assert chat().count(prompt)==initial+1
    shift(key,False)
    action(PLAYER,10)
    assert READY in tags(PLAYER)
    wait(lambda:"已准备的玩家会开始游戏" in chat(),"updated ready copy")
    pos="["+", ".join(f"{float(c)}d" for c in ROSTER)+"]"
    board=entity("sd.camp_roster")
    wait(lambda:pos in command(f"execute in minecraft:overworld run data get entity {board} Pos"),"roster moved")
    assert "passed" in command("execute in minecraft:overworld if block 255 80 20 air").lower()
    shift(key,True)
    step()
    assert chat().count(prompt)==initial+1 and "取消准备" in chat()
    shift(key,False)
    action(PLAYER,5)
    wait(lambda:READY not in tags(PLAYER),"cancel readiness")
    print("Camp stays quiet on repeated steps, shows cancellation when ready, and grants lobby regeneration.",flush=True)


def check_study(key):
    command("execute in minecraft:overworld run forceload add -101 48")
    wait(lambda:"passed" in command("execute in minecraft:overworld if loaded -101 89 48").lower(),"load former study")
    assert "passed" in command("execute in minecraft:overworld if block -101 89 48 air").lower()
    command("execute in minecraft:overworld run forceload remove -101 48")
    move(PLAYER,TUTORIAL,"minecraft:overworld")
    shift(key,True)
    wait(lambda:dimension(PLAYER,STUDY),"enter dedicated study")
    shift(key,False)
    wait(lambda:"passed" in command(f"execute in {STUDY} if block -100 90 46 lectern").lower()
         and status("#edu_live")==1,"tutorial actors initialized")
    assert "Found no elements" not in command(f"execute in {STUDY} run data get block -100 90 46 Book")
    page=status("#edu_page")
    command(f"execute in {STUDY} run setblock -100 90 49 polished_blackstone_button[face=floor,facing=east,powered=true]")
    wait(lambda:status("#edu_page")==page % 7+1,"tutorial next button advances in the new dimension")
    command(f"execute in {STUDY} run setblock -100 90 49 polished_blackstone_button[face=floor,facing=east,powered=false]")
    assert "passed" in command(f"execute in {STUDY} unless block -101 89 48 air").lower()
    assert HEALING not in tags(PLAYER)
    action(PLAYER,3)
    wait(lambda:dimension(PLAYER,"minecraft:overworld"),"return from study")
    print("The old Overworld tutorial was cleared and the independent study remains usable.",flush=True)


def check_training(key):
    move(PLAYER,(275.5,78,30.5),"minecraft:overworld")
    shift(key,True)
    wait(lambda:dimension(PLAYER,TRAINING_DIM),"training dimension")
    shift(key,False)
    wait(lambda:"1b" in storage("overlimit_spot","sweetdream_floor:training"),"Overlimit bench built")
    action(PLAYER,100)
    wait(lambda:"通用装备" in chat() and "职业装备" in chat(),"training categories")
    action(PLAYER,110)
    wait(lambda:"常器" in chat() and "秘器" in chat(),"rarity categories")
    action(PLAYER,111)
    wait(lambda:"魔导士" in chat(),"separate job category")
    action(PLAYER,120)
    wait(lambda:"show_item" in storage("row",PREVIEW),"catalog item preview")
    route=native.NATIVE/"world/datapacks/zz_sweetdream_floor/data/sweetdream_floor/function/lobby/practice/route.mcfunction"
    grant=re.search(r'matches (\d+) run return run give @s .*?\bzx:\["tidemark"',route.read_text(encoding="utf8"))[1]
    action(PLAYER,int(grant))
    command(f"item replace entity {PLAYER} weapon.offhand from entity {PLAYER} hotbar.0")
    move(PLAYER,tuple(map(float,BENCH.split())),TRAINING_DIM)
    shift(key,True)
    wait(lambda:"passed" in command(f'execute if items entity {PLAYER} weapon.offhand '
                                     '*[minecraft:custom_data~{ol:"tidemark",sd_training:1b}]').lower(),"apply actual Overlimit")
    shift(key,False)
    action(PLAYER,3)
    wait(lambda:dimension(PLAYER,"minecraft:overworld"),"return after testing gear")
    print("Rarity catalog, item tooltips, and an actual training Overlimit application passed.",flush=True)


def check_doors():
    command(f"execute in {DIM} run forceload add -32 32 -16 63")
    wait(lambda:"passed" in command(f"execute in {DIM} if loaded -20 81 45").lower(),"load door fixture")
    for x,z in ((-17,45),(-24,52)):
        command(f"execute in {DIM} run setblock {x} 80 {z} mossy_stone_bricks")
    command("scoreboard players set #door_closed sd.floor 1")
    command(f"execute in {DIM} as {PLAYER} run function sweetdream_floor:room/doors/update {{x:-24,z:45,radius:7}}")
    for x,z in ((-17,42),(-27,52)):
        assert "passed" in command(f"execute in {DIM} if block {x} 81 {z} barrier").lower()
        count=command(f"execute in {DIM} positioned {x}.0 81 {z}.0 if entity "
                      "@e[type=minecraft:block_display,tag=sd.floor_gate,distance=..0.01]")
        assert "count: 35" in count,count
    print("All 35 wooden panels align with the collision blocks in both orientations.",flush=True)


if __name__ == "__main__":
    verify()
