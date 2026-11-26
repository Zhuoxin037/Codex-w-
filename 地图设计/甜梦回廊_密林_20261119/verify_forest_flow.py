"""Exercise room locks, shared exploration, hidden shortcuts and damage in 1.21.5."""

import math
import re
import time

from world import ROOT, native
import verify
import verify_forest_revision as base
from architecture import radius
from cabin_lobby import CAMP
from floor_upgrade import DIM
from forest_junctions import PAIRS
from verify import OTHER, PLAYER, phase, status, storage, tags, wait
from verify_dimension import cells, doors, floor_block, map_edges

action = base.action
c = native.c


def move(player, x, z):
    c(f"execute in {DIM} run tp {player} {x} 81 {z}")


def room(player, cell, dx=4):
    x,z,_,i=cell
    move(player,x+dx+.5,z+.5)
    wait(lambda:status(player,"zx.rg_room")==i,f"{player} entered {i}")


def has_room(index):
    return f"{{cell: {index}}}" in storage("rooms")


def position(player):
    line=c(f"data get entity {player} Pos")
    return tuple(float(s) for s in re.findall(r"(-?\d+(?:\.\d*)?)d",line))


def health(player):
    return float(c(f"data get entity {player} Health").rsplit(" ",1)[1].rstrip("f"))


def verify_flow():
    native.WORK=ROOT/".workbuddy/rogue_forest_flow_20261124"
    native.NATIVE=native.WORK/"server"
    native.rcon.D=native.NATIVE
    verify.WORK=native.WORK
    if PLAYER not in c("list"):
        native.clients()
    for player in (PLAYER,OTHER):
        if "sd.floor_run" in tags(player):
            action(3,player)
    wait(lambda:phase()==0 and status("#rv_clean","zx.meta")==0,"clear previous run and drawers")
    x,y,z=CAMP
    c(f"execute in minecraft:overworld run tp {OTHER} {x} {y} {z}")
    wait(lambda:"sd.floor_pad" in tags(OTHER),"second player arrives at camp")
    action(11,OTHER)
    wait(lambda:"sd.lobby_ready" in tags(OTHER),"second player is ready")
    c(f"execute in minecraft:overworld run tp {PLAYER} {x} {y} {z}")
    wait(lambda:"sd.floor_pad" in tags(PLAYER),"first player arrives at camp")
    action(10)
    wait(lambda:"sd.lobby_ready" in tags(PLAYER),"first player is ready")
    action(4)
    wait(lambda:"sd.floor_hud" in tags(PLAYER),"first player arrives on the floor",60)
    layout=cells()
    wait(lambda:"sd.floor_hud" in tags(OTHER),"second player arrives on the floor",60)
    pick=lambda kind: next(x for x in layout.values() if x[2]==kind)

    entrance=pick("entry")
    merchant=pick("merchant")
    forge=pick("forge")
    astrologer=pick("astrology")
    explore=lambda player: status(player,"sd.explore")
    assert explore(PLAYER)==explore(OTHER)==8
    room(PLAYER,merchant)
    assert explore(PLAYER)==7 and explore(OTHER)==8
    room(OTHER,merchant)
    assert explore(PLAYER)==explore(OTHER)==7
    room(OTHER,forge)
    assert explore(PLAYER)==7 and explore(OTHER)==6
    c(f"scoreboard players set {PLAYER} sd.explore 0")
    c(f"scoreboard players set {OTHER} sd.explore 1")
    x,z,_,_=astrologer
    move(PLAYER,x+4.5,z+.5)
    wait(lambda:abs(position(PLAYER)[0]-merchant[0])<=5 and status(PLAYER,"zx.rg_room")==merchant[3],
         "unfunded exploration returns the scout to their last room")
    assert explore(PLAYER)==0 and explore(OTHER)==1
    c(f"scoreboard players set {OTHER} sd.explore 2")
    room(PLAYER,astrologer)
    assert explore(PLAYER)==explore(OTHER)==0
    room(OTHER,astrologer)
    assert explore(OTHER)==0
    room(PLAYER,merchant)
    assert explore(PLAYER)==0
    assert "Found no elements" in storage("exploration_doors")
    for player in (PLAYER,OTHER):
        c(f"scoreboard players set {player} sd.explore 8")
    print("PASS Personal charges, free revisits, two-point sponsorship and insufficent funding with no debit.",flush=True)

    event=pick("event")
    room(PLAYER,event)
    room(OTHER,event)
    room(PLAYER,entrance)
    assert not has_room(event[3])
    room(OTHER,entrance)
    wait(lambda:has_room(event[3]),"event expires when the last player leaves")
    room(PLAYER,event)
    wait(lambda:has_room(event[3]),"expired event remains spent")
    print("PASS A random encounter survives for a remaining teammate and expires when everyone leaves.",flush=True)

    brush=storage("shrub")
    if 'edge:' in brush:
        assert_shortcut(layout,brush)
    elite=pick("elite")
    x,z,_,i=elite
    room(PLAYER,elite,dx=radius("elite")-2)
    wait(lambda: f"cell: {i}" in storage("encounter"),"elite gates close")
    wait(lambda:status(OTHER,"zx.rg_room")==i,"remote teammate lands in elite room")
    assert abs(position(OTHER)[0]-x)<6 and abs(position(OTHER)[2]-z)<6
    move(PLAYER,x+11.5,z+.5)
    time.sleep(.2)
    assert abs(position(PLAYER)[0]-x-11.5)<.25
    gates=list(doors(elite,map_edges()))
    assert gates
    for xx,zz,dx,dz in gates:
        assert all(floor_block(xx+(off if dz else 0),y,zz+(off if dx else 0),"barrier")
                   for off in (-3,0,3) for y in (81,82,83,84,85))
    action(20)
    wait(lambda:phase()==2,"start elite near the wall")
    assert "94.0f" in c(f"execute in {DIM} run data get entity @e[tag=sd.mob.crown,limit=1] Health")
    c(f"execute in {DIM} run kill @e[tag=sd.floor_enemy,distance=0..]")
    c(f"execute in {DIM} run kill @e[tag=sd.mob.resin_pending,distance=0..]")
    wait(lambda:phase()==3,"elite reward")
    assert f"cell: {i}" in storage("choice_room")
    xx,zz,_,_=gates[0]
    assert floor_block(xx,82,zz,"barrier")
    move(PLAYER,entrance[0]+4.5,entrance[1]+.5)
    wait(lambda:abs(position(PLAYER)[0]-x)<6 and abs(position(PLAYER)[2]-z)<6,"blink cannot escape pending reward")
    action(115,OTHER)
    assert phase()==1 and "source:" in storage("draw_stash[0]")
    assert "Found no elements" in storage("choice_room")
    assert floor_block(xx,82,zz,"light[level=15]")
    assert floor_block(xx,81,zz,"air")
    assert_impact()
    print("PASS Near-rim elite starts, teammates move normally, and both remain locked until the draw is resolved.",flush=True)
    c("save-all flush")


def assert_shortcut(rooms,brush):
    fields={k:int(re.search(rf"\b{k}: (\d+)",brush)[1]) for k in ("edge","a","b","r1","r2")}
    edge,a,b,ra,rb=(fields[k] for k in ("edge","a","b","r1","r2"))
    edges=map_edges()
    assert edges[edge]=="0"
    visited={a}
    while True:
        extended=visited | {n for e,(u,v,_) in zip(edges,PAIRS) if e=="1" and (u in visited or v in visited) for n in (u,v)}
        if extended==visited:
            break
        visited=extended
    assert b in visited
    x,z,_,_=rooms[a]
    at=lambda along: (x+along,z) if edge<20 else (x,z+along)
    xx,zz=at((ra+36-rb)//2)
    assert floor_block(xx,80,zz,"air")
    bx,bz=at(ra)
    assert floor_block(bx,82,bz,"azalea_leaves[persistent=true]")
    print("PASS The shrub sits on an absent edge with an alternate path and no prebuilt corridor.",flush=True)


def assert_impact():
    for slot,item in (("head","netherite_helmet"),("chest","netherite_chestplate"),
                      ("legs","netherite_leggings"),("feet","netherite_boots")):
        c(f"item replace entity {PLAYER} armor.{slot} with minecraft:{item}")
    c(f"effect give {PLAYER} instant_health 1 4 true")
    time.sleep(.1)
    before=health(PLAYER)
    c(f"execute as {PLAYER} at @s run function sweetdream_floor:combat/mobs/impact {{power:500,cap:25}}")
    dealt=before-health(PLAYER)
    assert math.isclose(dealt,2.1,abs_tol=.06),dealt
    for slot in ("head","chest","legs","feet"):
        c(f"item replace entity {PLAYER} armor.{slot} with minecraft:air")
    c(f"attribute {PLAYER} minecraft:max_health modifier add sweetdream_floor:test_low -10 add_value")
    c(f"effect give {PLAYER} instant_health 1 4 true")
    time.sleep(.65)
    assert health(PLAYER)==10 and "is 0.0" in c(f"attribute {PLAYER} minecraft:armor get")
    c(f"execute as {PLAYER} at @s run function sweetdream_floor:combat/mobs/impact {{power:500,cap:25}}")
    assert math.isclose(health(PLAYER),7.5,abs_tol=.06),health(PLAYER)
    c(f"attribute {PLAYER} minecraft:max_health modifier remove sweetdream_floor:test_low")
    print("PASS Root hit inflicted 2.1 through twenty armor, while the unarmored 10-HP player lost 2.5.",flush=True)


if __name__=="__main__":
    verify_flow()
