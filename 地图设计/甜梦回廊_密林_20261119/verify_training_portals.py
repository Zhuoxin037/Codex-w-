"""Exercise actual Shift input, the saved lobby updates, and dummy deduplication."""

import json
import subprocess

from cabin_lobby import TUTORIAL
from lobby_expansion import DUMMY, DUMMY_PADS, TRAINING_DIM, coords
from lobby_metrics import OBJ
from training_world import EXIT, STORE
from world import ROOT, native
from verify import PLAYER, command, status, storage, tags, wait
from verify_lobby import action, dimension
from verify_training_world import move


def client(work, capture_chat=False):
    cfg = json.loads((native.NATIVE/"connection.json").read_text(encoding="utf8"))
    protocol = ROOT/".workbuddy/tools/husk_player_probe/node_modules/minecraft-protocol"
    key = work/"shift.txt"
    key.write_text("0",encoding="ascii")
    script = work/"shift-client.js"
    script.write_text(f"""
const fs = require('fs');
const mc = require({json.dumps(str(protocol))});
const client = mc.createClient({{host:"127.0.0.1",port:{cfg['game']},
  username:{json.dumps(PLAYER)},auth:"offline",version:"1.21.5"}});
let entityId = null, last = null;
client.on("login", packet => entityId = packet.entityId);
client.on("position", packet => {{
  client.write("teleport_confirm", {{teleportId:packet.teleportId}});
  client.write("player_loaded", {{}});
}});
client.on("end", () => process.exit(0));
if ({str(capture_chat).lower()}) client.on("system_chat", data => console.log(JSON.stringify(data.content)));
setInterval(() => {{
  const pressed = fs.readFileSync({json.dumps(str(key))}, "ascii") === "1";
  if (entityId !== null && pressed !== last) {{
    client.write("player_input", {{inputs:{{shift:pressed}}}});
    client.write("entity_action", {{entityId, actionId:pressed?"start_sneaking":"stop_sneaking", jumpBoost:0}});
    last = pressed;
  }}
}}, 35);
setTimeout(() => process.exit(0),120000);
""",encoding="utf8")
    with (work/"shift-client.log").open("w",encoding="utf8") as log:
        proc = subprocess.Popen(["node",str(script)],cwd=work,stdin=subprocess.DEVNULL,
                                stdout=log,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
    return proc,key


def shift(key, pressed):
    key.write_text("1" if pressed else "0",encoding="ascii")
    def received():
        command(f"execute store success score #shift_probe {OBJ} run execute as {PLAYER} "
                "at @s if predicate sweetdream:is_sneaking")
        return status("#shift_probe",OBJ)==int(pressed)
    wait(received, f"server received shift={pressed}")


def step(n=12):
    stop = status("#clock",OBJ)+n
    wait(lambda: status("#clock",OBJ)>=stop, f"advance {n} ticks")


def entity(tag):
    return f"@e[tag={tag},distance=0..,limit=1]"


def count(tag):
    return command(f"execute in {TRAINING_DIM} if entity @e[tag={tag},distance=0..]")


def verify():
    work = ROOT/".workbuddy/rogue_training_portals_20261123"
    native.WORK = work
    native.NATIVE = work/"final"
    native.rcon.D = native.NATIVE
    proc,key = client(work)
    try:
        check(key)
    finally:
        proc.terminate()
        proc.wait(timeout=5)


def check(key):
    wait(lambda: "sd.floor_seen" in tags(PLAYER), "client joined the lobby")
    wait(lambda: all("1b" in storage(flag,STORE) for flag in ("gate_ui","tutorial_ui","old_yard")),
         "portal signs and old clearing applied to the save",45)
    assert "passed" in command("execute in minecraft:overworld if block 285 77 30 water").lower()
    assert "passed" in command("execute in minecraft:overworld if block 287 80 37 lantern").lower()
    assert "passed" in command("execute in minecraft:overworld if block 275 77 30 waxed_oxidized_cut_copper").lower()
    assert "潜行进入" in command(f"execute in minecraft:overworld run data get entity {entity('sd.tutorial_gate_sign')} text")
    assert "潜行进入" in command(f"execute in minecraft:overworld run data get entity {entity('sd.training_gate_sign')} text")

    shift(key,True)
    action(PLAYER,2)
    step()
    assert "sd.floor_tutorial" not in tags(PLAYER)
    shift(key,False)
    move(PLAYER,TUTORIAL,"minecraft:overworld")
    step()
    action(PLAYER,2)
    assert "sd.floor_tutorial" not in tags(PLAYER)
    shift(key,True)
    wait(lambda: "sd.floor_tutorial" in tags(PLAYER), "sneak on amethyst to open the tutorial")
    shift(key,False)
    action(PLAYER,3)
    wait(lambda: "sd.floor_tutorial" not in tags(PLAYER), "return from the tutorial")

    move(PLAYER,(275.5,78,30.5),"minecraft:overworld")
    step()
    assert dimension(PLAYER,"minecraft:overworld")
    shift(key,True)
    wait(lambda: dimension(PLAYER,TRAINING_DIM), "sneak on copper to enter training")
    shift(key,False)
    wait(lambda: "count: 2" in count(DUMMY), "two training dummies loaded")
    assert "返回大厅" in command(f"execute in {TRAINING_DIM} run data get entity {entity('sd.training_exit')} text")
    assert "原装备" not in command(f"execute in {TRAINING_DIM} run data get entity {entity('sd.training_exit')} text")
    print("Both entrances require real Shift input. Signs and garden blocks loaded.",flush=True)

    point0,point1 = DUMMY_PADS
    command(f"execute in {TRAINING_DIM} run tp {entity(DUMMY+'_0')} {coords(point1)}")
    step()
    assert "count: 2" in count(DUMMY)
    pos = "["+", ".join(f"{float(c)}d" for c in point0)+"]"
    assert pos in command(f"execute in {TRAINING_DIM} run data get entity {entity(DUMMY+'_0')} Pos")
    command(f"execute in {TRAINING_DIM} run summon minecraft:husk {coords(point0)} "
            f'{{Tags:["{DUMMY}","{DUMMY}_0"],NoAI:1b,Health:1024f,'
            'attributes:[{id:"minecraft:max_health",base:1024d}]}')
    step()
    assert "count: 2" in count(DUMMY)
    assert "count: 1" in count(DUMMY+"_0")
    assert "count: 1" in count(DUMMY+"_1")
    assert status("#sum0",OBJ)==0 and status("#sum1",OBJ)==0
    print("Moving one dummy onto the other was corrected. A deliberately added duplicate was removed without counting damage.",flush=True)

    shift(key,True)
    move(PLAYER,EXIT,TRAINING_DIM)
    wait(lambda: dimension(PLAYER,"minecraft:overworld"), "exit while sneaking")
    step()
    assert dimension(PLAYER,"minecraft:overworld")
    shift(key,False)
    step()
    shift(key,True)
    wait(lambda: dimension(PLAYER,TRAINING_DIM), "release and sneak again at the same gate")
    shift(key,False)
    action(PLAYER,3)
    wait(lambda: dimension(PLAYER,"minecraft:overworld"), "return after repeat entry")
    print("Holding Shift while returning did not bounce the player back into training.",flush=True)


if __name__ == "__main__":
    verify()
