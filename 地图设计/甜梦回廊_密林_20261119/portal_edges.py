"""Keep the four visible room exits and their door geometry on the same grid."""

from architecture import Build
from floor_route_map import EDGES


F = "sweetdream_floor:"
P = F+"routes/portal/"
RUN = F+"run"
GRAPH = "zx:rogue"
SIDES = (("north",0,-1),("east",1,0),("south",0,1),("west",-1,0))


def local(*values):
    return " ".join(f"~{v or ''}" for v in values)


def generate(mc,read):
    original=F+"room/doors/update"
    mc(original,
       f"$execute if data storage {GRAPH} floor.cells[{{cell:$(cell),isolated:1b}}] "
       f"run return run function {P}locate {{x:$(x),z:$(z),radius:$(radius),cell:$(cell),operation:\"lock\"}}",
       *read(original))
    mc(P+"build",
       f"$function {P}locate {{x:$(x),z:$(z),radius:$(radius),cell:$(cell),operation:\"build\"}}")
    mc(P+"locate",f"$execute positioned $(x) 81 $(z) align xyz run function {P}cell_$(cell) "
       '{radius:$(radius),operation:"$(operation)"}')
    look=[]
    for cell in range(25):
        look.append(f"execute if score @s zx.rg_room matches {cell} "
                    f"if data storage {GRAPH} floor.cells[{{cell:{cell},present:1b,isolated:1b}}] "
                    f"run return run function {P}visit with storage {GRAPH} floor.cells[{cell}]")
        routes=[]
        for direction,sx,sz in SIDES:
            col,row=cell%5+sx,cell//5+sz
            if not (0<=col<5 and 0<=row<5):
                continue
            target=row*5+col
            edge=EDGES.index(tuple(sorted((cell,target))))
            xr,zr=[f"~{'-' if n<0 else ''}$(radius)" if n else "~" for n in (sx,sz)]
            routes.extend((
                f"execute store result score #portal_edge sd.floor run data get storage {GRAPH} floor.edges[{edge}]",
                f"execute if data storage {RUN} shrub{{edge:{edge}}} run scoreboard players set #portal_edge sd.floor 1",
                f"$execute if score #portal_edge sd.floor matches 1 positioned {xr} ~ {zr} "
                f"run function {P}$(operation)/{direction} {{cell:{cell},target:{target},edge:{edge}}}",
            ))
        mc(P+f"cell_{cell}",*routes)
    mc(F+"routes/find_exit",*look)
    mc(P+"visit",
       f"$function {P}locate {{x:$(x),z:$(z),radius:$(radius),cell:$(cell),operation:\"enter\"}}")
    for name,sx,sz in SIDES:
        geometry(mc,name,sx,sz)
    mc(P+"arrived",
       "tag @s remove sd.room_road",
       "execute if entity @s[tag=rgp.open] run function fallenroute:floor/close",
       "execute if entity @s[tag=sdc.open] run function sweetdream_floor:wardrobe/close",
       "return 1")
    animate_gates(mc)
    shrub=F+"junction/build_shrub"
    mc(shrub,*(line for line in read(shrub) if F+"junction/closed_panel" not in line),
       *(f"$function {P}build with storage {GRAPH} floor.cells[$({end})]" for end in ("a","b")))
    furnish=F+"scene/furnish"
    mc(furnish,*read(furnish),
       f"$execute if data storage {GRAPH} floor.cells[{{cell:$(cell),isolated:1b}}] "
       f"run function {P}build with storage {GRAPH} floor.cells[$(cell)]")


def geometry(mc,name,sx,sz):
    horizontal="x" if sz else "z"

    def point(lateral,height,depth):
        return (lateral if sz else depth*sx,height,depth*sz if sz else lateral)

    b=Build(relative=True)
    b.box(point(-2,-1,-2),point(2,-1,0),"blackstone")
    b.box(point(-1,0,-2),point(1,2,-1),"air")
    for side in (-2,2):
        b.box(point(side,0,-2),point(side,3,0),"stripped_dark_oak_log")
    b.box(point(-2,3,-2),point(2,3,0),f"dark_oak_log[axis={horizontal}]")
    b.box(point(-1,0,0),point(1,2,0),"black_concrete")
    # The jambs, collision plane and panel anchors use actual block corners.
    mc(P+f"build/{name}",*b.lines,
       f"$execute if data storage {RUN} shrub{{edge:$(edge)}} unless data storage {RUN} shrub{{open:1b}} "
       f"run function {P}brush/{name}")
    brush=Build(relative=True)
    brush.box(point(-1,0,-1),point(1,2,-1),"azalea_leaves[persistent=true]")
    brush.set(*point(-1,1,-1),"flowering_azalea_leaves[persistent=true]")
    brush.set(*point(1,2,-1),"flowering_azalea_leaves[persistent=true]")
    brush.box(point(-1,-1,-2),point(1,-1,-1),"rooted_dirt")
    bx,bz=.5-sx*2.15,.5-sz*2.15
    hitbox=local(bx,0,bz)
    facade=local(.5-sx*1.58,1.65,.5-sz*1.58)
    turn="[0f,.707107f,0f,.707107f]" if sx else "[0f,0f,0f,1f]"
    mc(P+f"brush/{name}", *brush.lines,
       f"execute positioned {hitbox} run kill @e[tag=sd.shrub_click,distance=..0.3]",
       f"execute positioned {facade} run kill @e[tag=sd.shrub_art,distance=..0.3]",
       f'summon minecraft:item_display {facade} {{Tags:["sd.shrub_art","sd.floor_junction"],'
       'item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"fallendream_dungeon:bramble_2"}},'
       f'width:4f,height:4f,brightness:{{block:13,sky:13}},transformation:{{translation:[0f,0f,0f],'
       f'left_rotation:{turn},scale:[3.6f,3.3f,1.25f],right_rotation:[0f,0f,0f,1f]}}}}',
       f'summon minecraft:interaction {hitbox} {{Tags:["sd.shrub_click","sd.floor_junction"],width:2.8f,height:2.7f,response:1b}}')
    plane=local(-sx,0,-sz)
    mc(P+f"lock/{name}",f"execute positioned {plane} align xyz run function {P}gate/{horizontal}")
    x0,z0=(-2 if sx>0 else 1, -1) if sx else (-1,-2 if sz>0 else 1)
    dx,dz= (1,2) if sx else (2,1)
    mc(P+f"enter/{name}",
       f"execute if block {plane} minecraft:barrier run return 0",
       f"$execute if data storage {RUN} shrub{{edge:$(edge)}} unless data storage {RUN} shrub{{open:1b}} run return 0",
       f"$execute positioned {local(x0,0,z0)} if entity @s[dx={dx},dy=2,dz={dz}] run function {P}hop/{name} {{target:$(target)}}")
    mc(P+f"hop/{name}",
       f"$function {F}routes/travel {{cell:$(target)}}",
       f"$execute if score @s zx.rg_room matches $(target) run return run function {P}arrived",
       f"execute at @s run tp @s {local(-sx*2.5,0,-sz*2.5)}")


def animate_gates(mc):
    for axis in ("x","z"):
        if axis=="x":
            start,end="~-1 ~ ~","~1 ~2 ~"
        else:
            start,end="~ ~ ~-1","~ ~2 ~1"
        marker=f"sd.rim_delay_{axis}"
        mc(P+f"gate/{axis}",
           f"execute if score #door_closed sd.floor matches 0 run return run function {P}opening/{axis}",
           f"kill @e[tag={marker},distance=..0.14]",
           "execute store result score #intact sd.floor if entity @e[tag=sd.isolated_gate,tag=!sd.floor_gate_open,distance=..0.14]",
           f"fill {start} {end} minecraft:barrier replace #sweetdream_floor:room_air",
           "execute if score #intact sd.floor matches 9 run return 0",
           "kill @e[tag=sd.isolated_gate,distance=..0.14]",
           f"function {P}panels/{axis}")
        mc(P+f"opening/{axis}",
           "execute unless block ~ ~ ~ minecraft:barrier run return 0",
           f"execute if entity @e[tag={marker},distance=..0.14] run return 0",
           f"execute as @e[tag=sd.isolated_gate,tag=!sd.floor_gate_open,distance=..0.14] run function {F}room/doors/sink",
           f"execute summon minecraft:marker run function {P}delay/{axis}")
        mc(P+f"delay/{axis}",f"tag @s add {marker}","scoreboard players set @s sd.floor 9")
        mc(P+f"done/{axis}",
           f"fill {start} {end} minecraft:air replace minecraft:barrier",
           "kill @s")
        rows=[]
        for column in range(-1,2):
            wood="stripped_spruce_log" if column==0 else "stripped_dark_oak_log"
            x,z=(column,0) if axis=="x" else (0,column)
            for height in range(3):
                rows.append(f'summon minecraft:block_display ~ ~ ~ {{Tags:["sd.isolated_gate","sd.floor_gate_row_{height}"],'
                            f'block_state:{{Name:"minecraft:{wood}",Properties:{{axis:"{axis}"}}}},'
                            f'transformation:{{translation:[{x}.0f,{height}.0f,{z}.0f],scale:[1f,1f,1f],'
                            'left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]},width:4f,height:3f,view_range:1f}')
        mc(P+f"panels/{axis}",*rows)
    mc(P+"tick",*(line for axis in ("x","z") for line in (
        f"scoreboard players remove @e[type=marker,tag=sd.rim_delay_{axis},distance=0..] sd.floor 1",
        f"execute as @e[type=marker,tag=sd.rim_delay_{axis},distance=0..,scores={{sd.floor=..0}}] at @s run function {P}done/{axis}",
    )))
