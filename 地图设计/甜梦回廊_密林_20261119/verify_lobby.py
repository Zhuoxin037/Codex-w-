"""Exercise the upgraded lobby and a two-player run on the private 1.21.5 server."""

from lobby_expansion import DUMMY, PRACTICING, RACK, READY
from forest_floors import NEXT
from world import ROOT, native
from verify import OTHER, PLAYER, command, phase, status, storage, tags, wait


def action(player, value):
    command(f"execute as {player} run trigger sd.floor_cmd set {value}")
    wait(lambda: status(player, "sd.floor_cmd") == 0, "process lobby action")


def move(player, x, y, z):
    command(f"execute in minecraft:overworld run tp {player} {x} {y} {z}")


def hp(player):
    return float(command(f"attribute {player} minecraft:max_health get").rsplit(" ",1)[1])


def dimension(player, world):
    return world in command(f"data get entity {player} Dimension")


def verify():
    native.WORK = ROOT/".workbuddy/rogue_forest_polish_20261123"
    native.NATIVE = native.WORK/"native"
    native.rcon.D = native.NATIVE
    if PLAYER not in command("list"):
        native.clients()
    wait(lambda: "1b" in storage("lobby_expansion"), "expanded lobby built", 45)
    wait(lambda: phase() == 0 and status("#rv_clean","zx.meta") == 0, "previous floor cleaned")
    command("execute in minecraft:overworld run forceload add 64 64")
    wait(lambda: "passed" in command("execute in minecraft:overworld if loaded 72 77 72").lower(),
         "load the retired prototype chunk")
    assert "passed" in command("execute in minecraft:overworld if block 72 77 72 minecraft:air").lower()
    command("execute in minecraft:overworld run forceload remove 64 64")

    move(PLAYER, *RACK)
    wait(lambda: "count: 2" in command(f"execute in minecraft:overworld if entity @e[tag={DUMMY},distance=0..]"),
         "both training dummies are present")
    assert "count: 4" in command("execute in minecraft:overworld if entity @e[type=minecraft:text_display,tag=sd.lobby_expansion,distance=0..]")
    assert "passed" in command("execute in minecraft:overworld if block 275 77 30 minecraft:spruce_planks").lower()
    command(f"advancement grant {PLAYER} only sweetdream_floor:lobby/rack_click")
    wait(lambda: PRACTICING in tags(PLAYER), "equipment rack opens")
    action(PLAYER,181)
    assert hp(PLAYER) == 10
    action(PLAYER,300)
    assert "Found" in command(f"clear {PLAYER} *[minecraft:custom_data~{{sd_training:1b}}] 0")
    target = f"@e[type=minecraft:husk,tag={DUMMY}_0,distance=0..,limit=1]"
    def dummy_hp():
        return float(command(f"execute in minecraft:overworld run data get entity {target} Health").rsplit(" ",1)[1][:-1])
    before = dummy_hp()
    command(f"execute in minecraft:overworld run damage {target} 12 minecraft:player_attack by {PLAYER}")
    assert 0 < dummy_hp() < before

    move(PLAYER, 257.5, 78, 15.5)
    move(OTHER, 258.5, 78, 16.5)
    wait(lambda: PRACTICING not in tags(PLAYER), "clean up on leaving training")
    assert "Found" not in command(f"clear {PLAYER} *[minecraft:custom_data~{{sd_training:1b}}] 0")
    assert hp(PLAYER) == 20
    action(PLAYER, 10)
    assert READY in tags(PLAYER) and phase() == 0
    action(OTHER, 11)
    assert READY in tags(OTHER) and phase() == 0
    command(f"advancement grant {PLAYER} only sweetdream_floor:lobby/camp_click")
    for each in (PLAYER, OTHER):
        wait(lambda: "sd.floor_hud" in tags(each) and dimension(each,"sweetdream:floor_1_forest"),
             f"{each} arrived in the same Forest", 60)
        assert READY not in tags(each)
    assert hp(OTHER) == 10 and hp(PLAYER) == 20
    print("Training gear, damageable dummies, four labels, and two-stage party start passed.",flush=True)

    command("scoreboard players set #phase sd.floor 5")
    action(PLAYER,82)
    for each in (PLAYER,OTHER):
        wait(lambda: "sd.floor_hud" in tags(each) and dimension(each,NEXT),
             f"{each} followed the party to the next floor",90)
    command(f"kill {OTHER}")
    wait(lambda: "sd.floor_run" not in tags(OTHER) and dimension(OTHER,"minecraft:overworld"),
         "fallen partner returns to the lobby")
    assert hp(OTHER) == 20
    assert phase() == 1 and "sd.floor_run" in tags(PLAYER)
    action(PLAYER,3)
    wait(lambda: phase()==0 and status("#rv_clean","zx.meta")==0,"last party member exits")
    assert hp(PLAYER)==20
    print("Party followed the floor transition; one death kept the run alive and restored 20 lobby HP.",flush=True)


if __name__ == "__main__":
    verify()
