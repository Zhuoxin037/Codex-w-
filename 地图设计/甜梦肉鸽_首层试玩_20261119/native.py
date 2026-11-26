"""Run a private vanilla 1.21.5 server against the staged world and probe over localhost."""
from pathlib import Path
import json
import os
import secrets
import socket
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
WORK = ROOT / ".workbuddy/rogue_floor_20261119"
NATIVE = WORK / "native"
sys.path.insert(0, str(ROOT / ".workbuddy"))
import husk_server_test_20261025 as rcon
rcon.D = NATIVE

def c(cmd):
    return rcon.command(cmd, timeout=40)

def port():
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]

def start():
    NATIVE.mkdir(parents=True, exist_ok=True)
    game, console = port(), port()
    pwd = secrets.token_hex(16)
    (NATIVE / "connection.json").write_text(json.dumps({"port": console, "password": pwd, "game": game}), encoding="utf-8")
    (NATIVE / "eula.txt").write_text("eula=true\n", encoding="utf-8")
    gen = json.dumps({"biome":"minecraft:the_void","layers":[{"height":1,"block":"minecraft:air"}]})
    (NATIVE / "server.properties").write_text(
        f"server-ip=127.0.0.1\nserver-port={game}\nonline-mode=false\n"
        f"enable-rcon=true\nrcon.port={console}\nrcon.password={pwd}\n"
        "view-distance=5\nsimulation-distance=4\nspawn-protection=0\nmax-players=3\n"
        "network-compression-threshold=-1\nlevel-name=world\n"
        f"level-type=minecraft\\:flat\ngenerator-settings={gen}\ngenerate-structures=false\n"
        "gamemode=adventure\ndifficulty=normal\nenable-command-block=false\n"
        "max-tick-time=120000\npause-when-empty-seconds=-1\nfunction-permission-level=4\n",
        encoding="utf-8",
    )
    cp = (ROOT / ".workbuddy/boss_server_check/classpath.txt").read_text(encoding="utf-8").strip()
    java = Path(os.environ["APPDATA"]) / ".minecraft/runtime/java-runtime-delta/bin/java.exe"
    with (NATIVE / "console.log").open("w", encoding="utf-8") as log:
        proc = subprocess.Popen(
            [str(java), "-XX:ActiveProcessorCount=3", "-Xms256M", "-Xmx1800M", "-cp", cp, "net.minecraft.server.Main", "--nogui"],
            cwd=NATIVE, stdin=subprocess.DEVNULL, stdout=log, stderr=subprocess.STDOUT,
            creationflags=subprocess.CREATE_NO_WINDOW,
        )
    for _ in range(180):
        content = (NATIVE / "console.log").read_text(encoding="utf-8", errors="replace")
        if proc.poll() is not None:
            raise RuntimeError(content[-4000:])
        if "Done (" in content:
            print("Vanilla server ready", flush=True)
            return
        time.sleep(0.5)
    raise TimeoutError("Vanilla server startup")

def clients():
    cfg = json.loads((NATIVE / "connection.json").read_text(encoding="utf-8"))
    pm = ROOT / ".workbuddy/tools/husk_player_probe/node_modules/minecraft-protocol"
    js = f"""
const mc = require({json.dumps(str(pm))});
for(const username of ['DuskProbe','OtherProbe']) {{
 const client = mc.createClient({{host:'127.0.0.1',port:{cfg['game']},username,auth:'offline',version:'1.21.5'}});
 client.on('login',()=>console.log('LOGIN '+username));
 client.on('position',p=>{{client.write('teleport_confirm',{{teleportId:p.teleportId}}); client.write('player_loaded',{{}});}});
 client.on('death_combat_event',()=>client.write('client_command',{{actionId:0}}));
 client.on('error',e=>console.log(e.message));
}}
setTimeout(()=>process.exit(),900000);
"""
    (WORK / "clients.js").write_text(js, encoding="utf-8")
    with (WORK / "clients.log").open("w", encoding="utf-8") as log:
        subprocess.Popen(["node", str(WORK / "clients.js")], cwd=WORK, stdin=subprocess.DEVNULL, stdout=log, stderr=subprocess.STDOUT, creationflags=subprocess.CREATE_NO_WINDOW)
    for _ in range(80):
        if "DuskProbe" in c("list") and "OtherProbe" in c("list"):
            print("Two private test players connected", flush=True)
            return
        time.sleep(0.25)
    raise TimeoutError("Test players did not connect")

if __name__ == "__main__":
    if sys.argv[1] == "start":
        start()
    elif sys.argv[1] == "clients":
        clients()
    elif sys.argv[1] == "cmd":
        print(c(sys.argv[2]))
