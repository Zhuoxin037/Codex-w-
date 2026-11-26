"""Verify rendered names, real health loss, and independent rolling totals."""

from lobby_expansion import DUMMY, DUMMY_PADS
from lobby_metrics import OBJ, STORE, WINDOW
from floor_upgrade import write
from world import ROOT, native
from verify import OTHER, PLAYER, command, status, storage, wait
from verify_lobby import action, move


def board(tag):
    return command(f"execute in minecraft:overworld run data get entity "
                   f"@e[type=minecraft:text_display,tag={tag},distance=0..,limit=1] text")


def ready(count, *names):
    def current():
        shown = board("sd.camp_roster")
        return status("#roster", OBJ) == count and all(name in shown for name in names) and '"selector"' not in shown
    wait(current, f"camp roster shows {count} ready and {names}")


def attack(i, damage):
    return command(f"execute in minecraft:overworld run damage "
                   f"@e[tag={DUMMY}_{i},distance=0..,limit=1] {damage} minecraft:magic by {PLAYER}")


def verify():
    native.WORK = ROOT/".workbuddy/rogue_lobby_metrics_20261123"
    native.NATIVE = native.WORK/"native"
    native.rcon.D = native.NATIVE
    probe = native.NATIVE/"world/datapacks/zz_sweetdream_floor/data/sweetdream_floor/function/lobby/metrics/probe_hits.mcfunction"
    target = f"@e[tag={DUMMY}_1,distance=..4,limit=1]"
    write(probe, "\n".join(line for amount in (4.25,7.5) for line in (
        f'data modify storage zx:in arg set value {{target:"{target}",damage:{amount},type:"sweetdream:parallel_true_damage"}}',
        "function sweetdream:api/damage",
    )))
    try:
        command("reload")
        run()
    finally:
        probe.unlink()


def run():
    if PLAYER not in command("list"):
        native.clients()
    wait(lambda: "1b" in storage("lobby_expansion"), "expanded lobby built",45)
    move(PLAYER,257.5,78,15.5)
    move(OTHER,258.5,78,16.5)
    ready(0)
    action(PLAYER,10)
    action(OTHER,11)
    ready(2,PLAYER,OTHER,"魔导士")
    action(OTHER,5)
    ready(1,PLAYER)
    assert OTHER not in board("sd.camp_roster")
    action(OTHER,14)
    ready(2,PLAYER,OTHER,"同生")
    move(OTHER,274.5,78,31.5)
    ready(1,PLAYER)
    assert OTHER not in board("sd.camp_roster")
    print("Live roster resolves names, selection, cancellation, and leaving the camp.",flush=True)

    move(PLAYER,282.5,78,35.5)
    wait(lambda: all(status(f"#hp{i}",OBJ) > 0 for i in (0,1)), "training samples initialized")
    wait(lambda: status("#sum0",OBJ) == 0 and status("#sum1",OBJ) == 0
         and "0.00" in board("sd.practice_board_0"), "no recent training damage")
    now = status("#clock",OBJ)
    attack(0,6.25)
    wait(lambda: status("#last0",OBJ) == 6250, "ordinary hit tracks actual lost health")
    assert status("#sum0",OBJ) == 6250 and status("#sum1",OBJ) == 0
    wait(lambda: "6.25" in board("sd.practice_board_0"), "first hit appears on the panel")
    until = int(storage("hits0[0].until",STORE).rsplit(" ",1)[1])
    assert now+WINDOW <= until <= status("#clock",OBJ)+WINDOW
    wait(lambda: status("#clock",OBJ) >= now+25, "stagger damage within the window")
    attack(0,5.5)
    wait(lambda: status("#sum0",OBJ) == 11750, "both hits in the five-second sum")

    point = " ".join(map(str,DUMMY_PADS[1]))
    command(f"execute in minecraft:overworld as {PLAYER} positioned {point} run function sweetdream_floor:lobby/metrics/probe_hits")
    wait(lambda: status("#sum1",OBJ) == 11750 and status("#last1",OBJ) == 7500,
         "two same-tick pack hits stay distinct for last-hit readout")
    def pair_display():
        shown = board("sd.practice_board_1")
        return "7.50" in shown and "11.75" in shown
    wait(pair_display, "same-tick sequence appears on the second panel")
    wait(lambda: status("#sum0",OBJ) == 5500, "first hit expires independently")
    wait(lambda: status("#sum0",OBJ) == 0 and status("#sum1",OBJ) == 0, "both windows return to zero")
    assert status("#last0",OBJ) == 5500 and status("#last1",OBJ) == 7500
    remaining = status("#hp0",OBJ)
    attack(0,2000)
    wait(lambda: status("#hp0",OBJ) == 1024000, "defeated dummy respawns")
    assert status("#last0",OBJ) == remaining and status("#sum0",OBJ) == remaining
    print("A vanilla hit, same-tick pack hits, separate dummy panels, and exact window expiry passed.",flush=True)


if __name__ == "__main__":
    verify()
