"""Probe the live first-floor route and stag behavior in an isolated 1.21.5 save."""

import re
import sys
import time

from world import native
import verify
from verify import PLAYER, phase, status, tags, wait
from verify_dimension import cells, move, visit
from verify_lobby import action
from cabin_lobby import CAMP
from floor_upgrade import DIM
from forest_stag import HEALTH, S
from stag_release import NATIVE, WORK

ACTOR = "@e[tag=sd.stag.actor,distance=0..,limit=1]"
BODY = "@e[tag=sd.stag.body,distance=0..,limit=1]"


def c(row):
    return native.c(row)


def at_floor(row):
    return c(f"execute in {DIM} run {row}")


def at_stag(row):
    return at_floor(f"execute as {ACTOR} at @s run {row}")


def count(selector):
    reply = at_floor(f"execute if entity {selector}")
    match = re.search(r"count: (\d+)",reply)
    return int(match[1]) if match else 0


def score(key):
    reply=at_floor(f"scoreboard players get {ACTOR} sd.stag.{key}")
    match=re.search(r"has (-?\d+)",reply)
    return int(match[1]) if match else None


def note(body):
    print(body,flush=True)


def damage_at(position, function, expected):
    c(f"effect clear {PLAYER}")
    c(f"effect give {PLAYER} instant_health 1 8 true")
    at_stag(f"tp {PLAYER} {position}")
    time.sleep(.65)
    value=lambda:float(c(f"data get entity {PLAYER} Health").rsplit(": ",1)[1].rstrip("f"))
    before=value()
    at_stag(f"function {S}{function}")
    time.sleep(.16)
    assert abs((before-value())-expected)<=.01, (function,before,value(),expected)


def smoke(fixture=False,boot=True):
    native.WORK,native.NATIVE,native.rcon.D = WORK,NATIVE,NATIVE
    verify.WORK=WORK
    if boot:
        native.start()
    try:
        if boot:
            native.clients()
        log=NATIVE/"console.log"

        def errors():
            return [l for l in log.read_text(encoding="utf-8",errors="replace").splitlines()
                    if ("ERROR" in l or "Failed to load function" in l) and "equipment/bow/README.md" not in l]

        assert not errors(), errors()
        if fixture:
            c("function stag_verify:geometry")
            time.sleep(.8)
            c("function stag_verify:arena")
            c("function stag_verify:geometry")
            boss = (144,144,"boss",24)
            c(f"execute as {PLAYER} at @s run function stag_verify:ready {{x:{boss[0]},z:{boss[1]}}}")
        else:
            if "sd.floor_run" in tags(PLAYER):
                c(f"tag {PLAYER} remove sd.floor_run")
                wait(lambda:phase()==0,"finish last fixture")
            move(*CAMP,"minecraft:overworld")
            wait(lambda:"sd.floor_pad" in tags(PLAYER),"reach the normal camp")
            action(PLAYER,10)
            move(*CAMP,"minecraft:overworld")
            c("scoreboard players set #rv_clean zx.meta 0")
            action(PLAYER,4)
            wait(lambda:"sd.floor_hud" in tags(PLAYER),"load the Forest")
            boss = next(cell for cell in cells().values() if cell[2]=="boss")
        visit(boss)
        action(PLAYER,20)
        wait(lambda:count(ACTOR)==1,"spawn the stag by challenging it")
        assert count("@e[tag=sd.kn.body,distance=0..]")==0
        assert count("@e[tag=sd.stag.form1,distance=0..]")==162
        assert f"{HEALTH}.0" in at_floor(f"attribute {BODY} minecraft:max_health get")
        passengers=at_floor('data get entity @e[tag=sd.stag.rig,distance=0..,limit=1] Passengers[0].id')
        assert "item_display" in passengers,passengers
        note(f"First-floor challenge spawned {HEALTH} HP stag, 162 mounted displays, and no knight")

        wait(lambda:count("@e[tag=sd.stag.root_effect,distance=0..]")>=1,"first attack telegraphs player location")
        c(f"effect give {PLAYER} resistance 8 4 true")
        c(f"effect give {PLAYER} instant_health 1 6 true")
        at_stag("scoreboard players set @s sd.stag.state 6")
        at_stag(f"function {S}clear_fx")
        at_stag("tp @s ~ ~ ~ 0 0")
        for slot in ("head","chest","legs","feet"):
            c(f"item replace entity {PLAYER} armor.{slot} with minecraft:air")
        damage_at("^ ^ ^5.35","geometry/sweep_hit",8.)
        damage_at("^ ^ ^-2.7","geometry/sweep_hit",0)
        damage_at("^1.3 ^ ^7.3","geometry/slam_hit",10.)
        damage_at("^3.1 ^ ^3.5","geometry/slam_hit",0)
        note("Sweep and slam hit the marked zone, leaving the rear and flanks safe")

        at_stag(f"tp {PLAYER} ^ ^ ^2.5")
        at_stag(f"function {S}hazard/resin_mark/2")
        wait(lambda:count("@e[tag=sd.stag.layer2,distance=0..]")==1,"resin lands")
        assert "minecraft:slowness" in c(f"data get entity {PLAYER} active_effects")
        at_stag(f"function {S}clear_fx")
        at_stag(f"execute positioned ^ ^ ^.35 run setblock ^2.35 ^2.65 ^2.65 minecraft:stone")
        at_stag(f"execute positioned ^ ^ ^.35 run function {S}move/rush")
        assert score("blocked")==1
        at_stag(f"execute positioned ^ ^ ^.35 run setblock ^2.35 ^2.65 ^2.65 minecraft:air")
        at_stag(f"execute positioned ^ ^ ^.35 run function {S}move/rush")
        assert score("blocked")==0
        note("Resin landed and slowed, and rush rejected an obstacle beside the centerline")

        at_floor(f"damage {BODY} {HEALTH//2+12} minecraft:magic")
        wait(lambda:score("form")==2,"shed the armor")
        assert count("@e[tag=sd.stag.form2,distance=0..]")==102
        assert count("@e[tag=sd.stag.form1,distance=0..]")==0
        actual=at_floor(f"data get entity {BODY} Health")
        assert f"{HEALTH//2-12}.0f" in actual,actual
        wait(lambda:score("state")!=7,"finish transformation")
        at_stag("scoreboard players set @s sd.stag.state 1")
        at_stag("scoreboard players set @s sd.stag.age 22")
        wait(lambda:score("age")>=27,"second sweep execution")
        note("Half health shed the outer shell while preserving HP and enabled the return sweep")

        at_floor(f"kill {BODY}")
        wait(lambda:phase()==4,"grant the existing Boss reward")
        assert status("#lumen")>=2
        assert count("@e[tag=sd.stag.part,distance=0..]")==0
        assert count("@e[tag=sd.stag.fx,distance=0..]")==0
        action(PLAYER,40)
        wait(lambda:phase()==5,"select the existing God-tier reward")
        assert not errors(), errors()
        note("Death cleaned up all displays and hazards, then completed the existing reward route")
    finally:
        if "--keep-server" not in sys.argv:
            try:
                c("stop")
            except OSError:
                pass


if __name__=="__main__":
    smoke("--fixture" in sys.argv)
