"""Remove the generated furniture from both newly built and existing cabins."""

from architecture import write
from cabin_finish import FINISH
from cabin_furnish import CLICK, MARKER, MOUNT, ROOT, TAG, furniture
from cabin_lobby import LOBBY_BOX, STORAGE, rewrite

REMOVED = "cabin_furniture_removed"


def stage(addon):
    functions = addon/"data/sweetdream_floor/function"
    lobby = functions/"lobby/cabin"
    setup = lobby/"furnish.mcfunction"
    cleanup = set()
    for name,_,commands in furniture():
        piece = lobby/f"furniture/{name}.mcfunction"
        shell = [line for line in piece.read_text(encoding="utf-8").splitlines()
                 if not line.startswith("summon ")]
        rewrite(setup,f"function {ROOT}/furniture/{name}\n",f"function {ROOT}/clear_space/{name}\n")
        write(lobby/f"clear_space/{name}.mcfunction",shell)
        piece.unlink()
        for line in commands:
            if line.startswith("summon minecraft:block_display ") and f'"{TAG}"' in line:
                cleanup.add(" ".join(line.split()[2:5]))
    for name in ("seat_tick","seat_click","seat_mount"):
        (lobby/f"{name}.mcfunction").unlink()
    tick = functions/"tick.mcfunction"
    seat_tick,rest = tick.read_text(encoding="utf-8").split("\n",1)
    assert seat_tick.endswith(f" run function {ROOT}/seat_tick")
    # A passenger saved in player data can restore its old mount after the upgrade.
    tick.write_text(f"execute as @a on vehicle if entity @s[type=minecraft:block_display,tag={MOUNT}] "
                    f"run kill @s\n{rest}",encoding="utf-8")
    write(lobby/"clear_furniture.mcfunction",[
        f"kill @e[type=minecraft:interaction,tag={CLICK},{LOBBY_BOX}]",
        f"kill @e[type=minecraft:block_display,tag={MOUNT},{LOBBY_BOX}]",
        *(f"execute positioned {pos} run kill @e[type=minecraft:block_display,tag={TAG},"
          "tag=sd.floor_lobby_display,distance=..0.0001]" for pos in sorted(cleanup)),
        "scoreboard players reset #seat_busy sd.floor",
        "scoreboard players reset #seat_mounted sd.floor",
        f"data modify storage {STORAGE} {REMOVED} set value 1b",
    ])
    rewrite(functions/"load.mcfunction",
            f"unless data storage {STORAGE} {{{MARKER}:1b}} run function {FINISH}_load",
            f"unless data storage {STORAGE} {{{REMOVED}:1b}} run function {FINISH}_load")
    run_clear = f"function {ROOT}/clear_furniture"
    rewrite(lobby/"ready_loaded.mcfunction",f"function {ROOT}/furnish\n",
            f"function {ROOT}/furnish\n{run_clear}\n")
    rewrite(lobby/"finish_loaded.mcfunction",f"run function {ROOT}/furnish\n",
            f"run function {ROOT}/furnish\n"
            f"execute unless data storage {STORAGE} {{{REMOVED}:1b}} run {run_clear}\n")
