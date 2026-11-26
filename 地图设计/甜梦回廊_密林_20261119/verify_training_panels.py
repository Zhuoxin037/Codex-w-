"""Exercise saved stacked text and real versus temporarily missing dummy health."""

from lobby_expansion import DUMMY, TRAINING_DIM
from lobby_metrics import OBJ, STORE
from verify_training_portals import client, count, dimension, entity, move, shift, step
from world import ROOT, native
from verify import PLAYER, command, status, storage, tags, wait


def verify():
    work=ROOT/".workbuddy/rogue_training_panels_20261123"
    native.WORK=work
    native.NATIVE=work/"final"
    native.rcon.D=native.NATIVE
    proc,key=client(work)
    try:
        wait(lambda:"sd.floor_seen" in tags(PLAYER),"lobby joined")
        wait(lambda:"1b" in storage("gate_ui","sweetdream_floor:training"),"training gate ready",40)
        # Represent the inflated last-hit cache found beside the stacked displays.
        command(f"scoreboard players set #last0 {OBJ} 1024000")
        command(f"scoreboard players set #last1 {OBJ} 1024000")
        command(f"data remove storage {STORE} damage_schema")
        wait(lambda:status("#last0",OBJ)==0 and status("#last1",OBJ)==0,"reset stale values")
        move(PLAYER,(275.5,78,30.5),"minecraft:overworld")
        shift(key,True)
        wait(lambda:dimension(PLAYER,TRAINING_DIM),"enter training")
        shift(key,False)
        wait(lambda:all("count: 1" in count(f"sd.practice_board_{i}") for i in (0,1)),
             "saved panels deduplicated")
        step()
        for i in (0,1):
            text=command(f"execute in {TRAINING_DIM} run data get entity {entity(f'sd.practice_board_{i}')} text")
            assert "单次伤害" in text and "0.00" in text and "1024.00" not in text,text
        print("Copied saved displays reduced to one per lane, and stale 1024 values were cleared.",flush=True)

        subject=entity(DUMMY+"_0")
        command(f"execute in {TRAINING_DIM} run damage {subject} 80 minecraft:magic by {PLAYER}")
        wait(lambda:status("#last0",OBJ)==80000,"real damage recorded")
        command(f"execute in {TRAINING_DIM} run tag {subject} remove {DUMMY}_0")
        step()
        assert status("#last0",OBJ)==80000 and status("#sum0",OBJ)==80000
        command(f"execute in {TRAINING_DIM} run kill @e[tag={DUMMY},tag=!{DUMMY}_0,tag=!{DUMMY}_1,distance=0..]")
        wait(lambda:status("#hp0",OBJ)==1024000 and "count: 1" in count(DUMMY+"_0"),"fresh dummy registered")
        command(f"execute in {TRAINING_DIM} run damage {subject} 2000 sweetdream:parallel_true_damage")
        wait(lambda:status("#last0",OBJ)==1024000,"confirmed lethal hit is recorded")
        step()
        assert status("#last1",OBJ)==0
        print("Absent/replaced and genuinely defeated dummies are distinguished.",flush=True)
    finally:
        proc.terminate()
        proc.wait(timeout=5)


if __name__ == "__main__":
    verify()
