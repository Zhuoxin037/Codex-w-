"""Exercise the actual migrated save through camp, study, equipment and brush."""

import json
import re
import time
from zipfile import ZipFile

from world import native
import verify
from verify import PLAYER, status, storage, tags, wait
from verify_dimension import cells, floor_block, map_edges
from verify_training_portals import client
from verify_lobby import action, dimension
from cabin_lobby import CAMP,TUTORIAL
from dream_pack_sync import WORK

c=native.c


def shift(key,pressed):
    key.write_text("1" if pressed else "0",encoding="ascii")
    def arrived():
        c(f"execute as {PLAYER} at @s store success score #newshift sd.floor if predicate fallendream:is_sneaking")
        return status("#newshift")==int(pressed)
    wait(arrived,"server received the client's sneak state")


def position(coord,target="minecraft:overworld"):
    c(f"execute in {target} run tp {PLAYER} {' '.join(str(n) for n in coord)}")


def main():
    native.WORK=WORK
    native.NATIVE=WORK/"native"
    native.rcon.D=native.NATIVE
    verify.WORK=WORK
    proc,key=client(WORK,capture_chat=True)
    chat=lambda: (WORK/"shift-client.log").read_text(encoding="utf8")
    try:
        wait(lambda:"sd.floor_seen" in tags(PLAYER),"join saved lobby")
        wait(lambda:"2b" in storage("entry_labels","sweetdream_floor:training"),"entry labels migrate")
        assert "选择职业" not in chat() and "研习" not in chat(),chat()[-600:]
        for tag,label,pos in (("sd.start_gate_sign","开始游戏","258.5"),("sd.tutorial_gate_sign","坠梦研习","266.5")):
            target=f"@e[type=text_display,tag={tag},limit=1]"
            assert "count: 1" in c(f"execute if entity @e[type=text_display,tag={tag}]")
            assert label in c(f"data get entity {target} text") and pos in c(f"data get entity {target} Pos")
        print("PASS Existing lobby has distinct labels and joining does not open a profession menu.",flush=True)

        position(TUTORIAL)
        shift(key,True)
        wait(lambda:dimension(PLAYER,"sweetdream:tutorial"),"sneak on the study portal")
        shift(key,False)
        book=c("execute in sweetdream:tutorial run data get block -100 90 46 Book")
        assert "坠梦" in book and "甜梦" not in book,book[:220]
        action(PLAYER,3)
        wait(lambda:dimension(PLAYER,"minecraft:overworld"),"return from study")
        assert "选择职业" not in chat()
        print("PASS The study portal and its renamed lecture work separately from the camp.",flush=True)

        position((275.5,78,30.5))
        shift(key,True)
        wait(lambda:dimension(PLAYER,"sweetdream:training"),"sneak on training portal")
        shift(key,False)
        c(f"execute as {PLAYER} at @s run function fallendream:equipment/sword/tidemark/give")
        assert "fallendream:tidemark" in c(f'data get entity {PLAYER} Inventory[{{components:{{"minecraft:custom_data":{{zx:["tidemark"]}}}}}}].components."minecraft:item_model"')
        count=c("execute store result score #catalog_count sd.floor run data get storage sweetdream_floor:pool entries")
        assert status("#catalog_count")==233,count
        action(PLAYER,3)
        wait(lambda:dimension(PLAYER,"minecraft:overworld"),"return from current training")
        print("PASS All 233 current entries loaded, and an issued weapon uses the new resource id.",flush=True)

        position(CAMP)
        action(PLAYER,10)
        wait(lambda:"sd.lobby_ready" in tags(PLAYER),"prepare at camp")
        assert "已准备" in chat()
        action(PLAYER,4)
        wait(lambda:"sd.floor_hud" in tags(PLAYER),"start and load current Forest",80)
        assert dimension(PLAYER,"sweetdream:floor_1_forest")
        assert "选择职业" not in chat()
        assert_shrub()
    finally:
        proc.terminate()
        proc.wait(timeout=5)


def assert_shrub():
    shrub=storage("shrub")
    if "edge:" not in shrub:
        # Some valid seeds contain no unused adjacent connection. Build a
        # display fixture on the test copy so the entity model is still checked.
        c("execute in sweetdream:floor_1_forest positioned 0 80 72 run function sweetdream_floor:junction/brush/east_13_13")
        x,z=13,72
    else:
        values={k:int(re.search(rf"\b{k}: (-?\d+)",shrub)[1]) for k in ("edge","x","z","r1")}
        x,z=values["x"],values["z"]
        if values["edge"]<20:
            x+=values["r1"]
        else:
            z+=values["r1"]
        assert map_edges()[values["edge"]]=="0"
    assert floor_block(x,82,z,"barrier")
    c(f"execute in sweetdream:floor_1_forest run forceload add {x} {z}")
    target=f"@e[type=item_display,tag=sd.shrub_art,x={x},y=81,z={z},distance=..5,limit=1]"
    model=c(f'execute in sweetdream:floor_1_forest run data get entity {target} item.components."minecraft:item_model"')
    file=re.search(r"fallendream_dungeon:(bramble_\d)",model)[1]
    with ZipFile(WORK/"native/world/resources.zip") as rp:
        key=f"assets/fallendream_dungeon/models/item/{file}.json"
        defined=json.loads(rp.read(key))
        assert len(defined["elements"])==49,defined.keys()
        for atlas in ("bramble_bark",file):
            assert rp.read(f"assets/fallendream_dungeon/textures/item/{atlas}.png").startswith(b"\x89PNG")
    print("PASS The shrub has its own baked geometry, texture, display entity and closed collision.",flush=True)


if __name__=="__main__":
    main()
