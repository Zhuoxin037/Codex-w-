"""Build the standalone 1.21.5 draw-animation rehearsal."""

from pathlib import Path
from random import Random
import json
import math
import re

from architecture import Build, LEAVES
from draw_lab_art import stage_resources


NS = "drawlab:"
SCORE = "dl.state"
LENGTH = 84
BUTTON = (2,82,2)
SPAWN = (.5,81,5.4)
ORIGIN = (.5,81,.5)
POOL = ("chenyuan","ablation","sail","deep_brine")


def compact(value):
    return json.dumps(value,ensure_ascii=False,separators=(",",":"))


def fn(name):
    return f"function {NS}{name}"


def coordinates(point):
    return ' '.join(f'{v:g}' for v in point)


def pos(x=0,y=0,z=0):
    return coordinates(tuple(round(a+b,4) for a,b in zip(ORIGIN,(x,y,z),strict=True)))


def cubic(t,a,b):
    u=max(0,min(1,(t-a)/(b-a)))
    return u*u*(3-2*u)


def mix(a,b,t):
    return a+(b-a)*t


def fl(value):
    return f"{value:.5f}f"


def q_y(theta):
    return "[0f,"+fl(math.sin(theta/2))+",0f,"+fl(math.cos(theta/2))+"]"


def select(tag):
    return f"@e[tag={tag},distance=0..,limit=1]"


def display(tag,model,location,*,scale=1,billboard="fixed",base="minecraft:paper",moving=False,ctx="none"):
    tags=compact(["dl.set" if not moving else "dl.play",tag])
    entity=(f'{{Tags:{tags},billboard:"{billboard}",brightness:{{block:15,sky:13}},view_range:1.0f,'
            f'teleport_duration:{2 if moving else 0},item_display:"{ctx}",'
            f'item:{{id:"{base}",count:1,components:{{"minecraft:item_model":"{model}"}}}},'
            f'transformation:{{translation:[0f,0f,0f],scale:[{fl(scale)},{fl(scale)},{fl(scale)}],'
            'left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}')
    return f"summon minecraft:item_display {location} {entity}"


def text_display(location,label,color,scale,*,tag="dl.set",bold=False):
    text=compact({"text":label,"color":color,"bold":bold})
    return (f'summon minecraft:text_display {location} {{Tags:["{tag}"],billboard:"vertical",'
            f'background:0,shadow:1b,brightness:{{block:15,sky:15}},text:{text},'
            f'transformation:{{translation:[0f,0f,0f],scale:[{fl(scale)},{fl(scale)},{fl(scale)}],'
            'left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}')


def item_pool(source):
    pool=(source/"pool/load.mcfunction").read_text(encoding="utf8").splitlines()
    rows={}
    for line in pool:
        if "entries append value " not in line:
            continue
        entry=json.loads(line.split("entries append value ",1)[1])
        if entry["group"]=="weapon" and entry["job"]==0 and entry["tier"]==3 and "yuanhai" in entry["tags"]:
            rows[entry["id"]]=entry["name"]
    assert set(rows)==set(POOL),rows
    result=[]
    for key in POOL:
        preview=(source/f"market/preview/{key}.mcfunction").read_text(encoding="utf8")
        item=re.search(r"item replace entity @s contents with ([\w:]+)\[",preview)[1]
        model=re.search(r'item_model\s*=\s*"([^"]+)"',preview)[1]
        result.append((rows[key],model,item if ":" in item else f"minecraft:{item}"))
    return result


def stage(world,source):
    gear=item_pool(source)
    pack=Path(world)/"datapacks/drawlab"

    def asset(relative,data):
        path=pack/relative
        path.parent.mkdir(parents=True,exist_ok=True)
        path.write_text(data+"\n",encoding="utf8")

    def mc(name,*lines):
        asset("data/drawlab/function/"+name+".mcfunction","\n".join(lines))

    asset("pack.mcmeta",compact({"pack":{"pack_format":71,"description":"坠梦 · 抽取动画实验"}}))
    for event in ("load","tick"):
        asset(f"data/minecraft/tags/function/{event}.json",compact({"values":[NS+event]}))
    world_setup(mc)
    controls(mc,gear)
    timeline(mc)
    stage_resources(world,(model for _,model,_ in gear))


def world_setup(mc):
    mc("load",f"scoreboard objectives add {SCORE} dummy",
       "gamerule doMobSpawning false","gamerule doWeatherCycle false","gamerule doDaylightCycle false",
       "gamerule spawnRadius 0","difficulty peaceful","time set 11040",
       f"execute in minecraft:overworld run {fn('reset')}",
       "execute in minecraft:overworld run forceload add -16 -16 16 16",
       f"execute unless score #built {SCORE} matches 1 run schedule function {NS}check_chunks 6t replace")
    mc("check_chunks",f"execute if score #built {SCORE} matches 1 run return 0",
       *(f"execute in minecraft:overworld unless loaded {x} 80 {z} run return run schedule function {NS}check_chunks 6t replace"
         for x in (-16,0,16) for z in (-16,0,16)),
       f"execute in minecraft:overworld run {fn('build')}")
    mc("build",*glade(), "setworldspawn 0 81 5 180",
       display("dl.base",NS+"pedestal",pos()),
       display("dl.dial",NS+"dial",pos()),
       display("dl.pointer",NS+"pointer",pos(0,1.055,1.25)),
       text_display(pos(0,3.15,-.28),"渊海 · 精器","#e5d2a7",1.13,bold=True),
       text_display(coordinates((BUTTON[0]+.5,BUTTON[1]+.37,BUTTON[2]+.5)),"抽取","#f3dbb2",.83),
       f"scoreboard players set #built {SCORE} 1")
    mc("reset",f"scoreboard players set #time {SCORE} -1",f"scoreboard players set #pressed {SCORE} 0",
       "kill @e[tag=dl.play,distance=0..]",
       f"data merge entity {select('dl.dial')} {{transformation:{{left_rotation:[0f,0f,0f,1f]}}}}")


def glade():
    b=Build()
    b.box((-14,77,-14),(14,79,14),"rooted_dirt")
    b.box((-14,80,-14),(14,80,14),"moss_block")
    b.disk(0,80,1,7,8,"mossy_stone_bricks")
    b.disk(0,80,1,6,7,"tuff_bricks")
    b.disk(0,80,0,4,4,"polished_tuff")
    b.disk(0,80,0,3,3,"chiseled_tuff")
    b.box((-2,80,4),(2,80,9),"polished_tuff")
    b.box((-1,80,8),(1,80,14),"coarse_dirt")
    rng=Random(42)
    for x,z,h in ((-10,-9,10),(-5,-12,10),(2,-13,9),(8,-11,11),(11,-7,9),(-12,-2,10),
                  (-11,5,8),(12,1,9),(10,6,10),(-7,11,8),(8,11,8)):
        b.oak(x,81,z,h,2+rng.randrange(2),leaves=LEAVES,thick=True)
    for x,z in ((-9,-6),(-11,3),(9,-4),(10,3),(-8,8),(8,9),(-3,-9),(4,-8)):
        for dx,dz in ((0,0),(1,0),(0,1),(-1,0)):
            b.set(x+dx,80,z+dz,rng.choice(("podzol","moss_block","coarse_dirt","rooted_dirt")))
            if rng.random()<.7:
                b.set(x+dx,81,z+dz,rng.choice(("fern","short_grass","moss_carpet","brown_mushroom")))
    for x,z in ((-5,-5),(5,-5),(-5,3),(5,3),(-4,8),(4,8)):
        b.set(x,81,z,"mossy_stone_brick_wall")
        b.set(x,82,z,"lantern")
    for x,z in ((-4,0),(4,0),(0,4),(0,-4),(-7,-3),(7,-3),(-6,7),(6,7)):
        b.set(x,83,z,"light[level=14]")
    for x,z,axis in ((-4,-8,"z"),(6,-6,"z"),(7,6,"x"),(-8,3,"x")):
        b.set(x,81,z,f"dark_oak_log[axis={axis}]")
        b.set(x,82,z,"moss_carpet")
    x,y,z=BUTTON
    b.set(x,y-1,z,"chiseled_tuff_bricks")
    b.set(*BUTTON,"polished_blackstone_button[face=floor,facing=north,powered=false]")
    return b.lines


def controls(mc,gear):
    mc("tick",f"execute in minecraft:overworld if score #built {SCORE} matches 1 run {fn('tick_stage')}")
    mc("tick_stage",f"execute as @a[tag=!dl.welcome,distance=0..] at @s run {fn('join')}",
       f"execute as @a[distance=0..] at @s if entity @s[y=40,dy=-103] run tp @s {coordinates(SPAWN)} 180 3",
       f"execute if score #time {SCORE} matches 0.. run {fn('advance')}",
       f"execute if block {coordinates(BUTTON)} minecraft:polished_blackstone_button[powered=true] run {fn('pressed')}",
       f"execute unless block {coordinates(BUTTON)} minecraft:polished_blackstone_button[powered=true] run scoreboard players set #pressed {SCORE} 0")
    mc("join","tag @s add dl.welcome","gamemode adventure @s",
       f"tp @s {coordinates(SPAWN)} 180 3",
       'tellraw @s {text:"按右前方的按钮抽取。",color:"gold"}')
    mc("pressed",f"execute if score #pressed {SCORE} matches 1 run return 0",
       f"scoreboard players set #pressed {SCORE} 1",
       f"execute if score #time {SCORE} matches ..-1 run {fn('start')}")
    mc("start","kill @e[tag=dl.play,distance=0..]",
       f"execute store result score #draw {SCORE} run random value 0..3",
       f"scoreboard players add #runs {SCORE} 1",
       f"scoreboard players set #time {SCORE} 0",
       *(f"execute if score #draw {SCORE} matches {index} run {fn(f'cast/{index}')}" for index in range(4)),
       f"playsound minecraft:block.amethyst_block.hit block @a[distance=..28] {pos()} .67 .72")
    for result,(name,_model,_base) in enumerate(gear):
        build=[]
        for slot in range(4):
            _,model,base=gear[(result+slot)%4]
            build.append(display(f"dl.card_{slot}",NS+"tablet",pos(0,.75),scale=.045,billboard="vertical",moving=True))
            build.append(display(f"dl.icon_{slot}",model,pos(0,.75,.092),scale=.042,billboard="vertical",base=base,
                                 moving=True,ctx="gui"))
        mc(f"cast/{result}",*build,fn("frames/0"))
        mc(f"result/{result}",text_display(pos(0,.46,1.63),name,"#f2d49b",1.16,tag="dl.play",bold=True))
    mc("advance",f"scoreboard players add #time {SCORE} 1",
       f"execute if score #time {SCORE} matches {LENGTH} run return run scoreboard players set #time {SCORE} -1",
       *(f"execute if score #time {SCORE} matches {n} run return run {fn(f'frames/{n}')}" for n in range(2,LENGTH,2)))


def update(tag,x,y,z,scale,angle=0,*,locate=pos):
    entity=select(tag)
    transform=f"{{scale:[{fl(scale)},{fl(scale)},{fl(scale)}],left_rotation:{q_y(angle)}}}"
    return [f"tp {entity} {locate(x,y,z)}",
            f"data merge entity {entity} {{start_interpolation:0,interpolation_duration:2,transformation:{transform}}}"]


def timeline(mc,*,count=4,length=LENGTH,locate=pos,directory="frames",reveal=None):
    if reveal is None:
        reveal=[f"execute if score #draw {SCORE} matches {i} run {fn(f'result/{i}')}" for i in range(4)]
    def move(*args):
        return update(*args,locate=locate)
    note={8:1.55,12:1.49,16:1.51,22:1.40,30:1.35,36:1.12,40:.88}
    for n in range(0,length,2):
        t=n/20
        wake=cubic(t,.11,.54)
        lock=cubic(t,2.04,2.44)
        burst=cubic(t,2.30,2.72)
        u=max(0,min(1,(t-.25)/1.82))
        yaw=math.pi/2+(1.75*(1-(1-u)**2.1)-1.75)*math.tau
        roll=t*(-.85)*(1-.72*lock)
        rows=[f"data merge entity {select('dl.dial')} {{start_interpolation:0,interpolation_duration:2,"
              f"transformation:{{left_rotation:{q_y(roll)}}}}}"]
        for slot in range(count):
            sink=cubic(t,1.59+slot*.135,1.93+slot*.135) if slot else 0
            death=next((k for k in range(0,LENGTH,2) if k/20>=1.93+slot*.135),0)
            if slot and n==death:
                rows.extend((f"kill {select(f'dl.card_{slot}')}",f"kill {select(f'dl.icon_{slot}')}"))
                continue
            if slot and sink>=.999:
                continue
            theta=yaw+slot*math.tau/count
            radius=mix(.36,1.20,wake)*(1-.31*sink)
            x=math.cos(theta)*radius
            z=math.sin(theta)*radius
            y=1.56-.60*(1-wake)-.89*sink+.013*math.sin(t*7+slot)
            scale=max(.045,wake*(1-.48*sink))
            if slot==0:
                x*=1-lock
                z=mix(z,.24,lock)
                y=mix(y,2.03,lock)
                scale=mix(scale,1.30,lock)
                if n==46:
                    rows.append(f"kill {select('dl.card_0')}")
                    for half in ("left","right"):
                        rows.append(display(f"dl.{half}",NS+"tablet_"+half,locate(x,y,z),
                                            scale=scale,billboard="vertical",moving=True))
                if 46<=n<58:
                    for half,direction in (("left",1),("right",-1)):
                        rows.extend(move(f"dl.{half}",x+direction*.59*burst,y-.57*burst,z-.035*burst,
                                           scale*(1-.49*burst),direction*.27*burst))
                elif n==58:
                    rows.extend(f"kill {select(f'dl.{half}')}" for half in ("left","right"))
            if slot!=0 or n<46:
                rows.extend(move(f"dl.card_{slot}",x,y,z,scale))
            hero=slot==0 and n>=46
            icon_scale=scale*(mix(.62,1.11,burst) if hero else .62)
            rows.extend(move(f"dl.icon_{slot}",x,y+.14*burst if hero else y,z+.082,icon_scale,.21*burst if hero else 0))
            if slot and .09<sink<.7:
                rows.append(f"particle minecraft:electric_spark {locate(x,y,z)} .10 .14 .12 .018 4 normal")
        if n in note:
            rows.append(f"playsound minecraft:block.note_block.bit block @a[distance=..28] {locate()} .29 {note[n]:g}")
        if n in range(8,44,4):
            for i in range(3):
                a=yaw-i*.26
                rows.append(f"particle minecraft:dust{{color:[.32,.73,.62],scale:.69}} "
                            f"{locate(1.25*math.cos(a),1.05,1.25*math.sin(a))} .022 .018 .022 0 2 normal")
        if n==42:
            rows.append(f"playsound minecraft:block.copper.place block @a[distance=..28] {locate()} .62 .83")
        if n==48:
            rows.append(f"playsound minecraft:block.amethyst_block.chime block @a[distance=..28] {locate(0,2.01,.33)} .8 1.26")
        if 48<=n<=58:
            radius=mix(.36,.89,burst)
            for i in range(16):
                a=i*math.tau/16
                rows.append(f"particle minecraft:dust{{color:[.46,.86,.74],scale:.63}} "
                            f"{locate(radius*math.cos(a),2.03+radius*math.sin(a),.32)} .018 .018 .014 0 1 normal")
        if n==52:
            rows.append(f"particle minecraft:end_rod {locate(0,2.03,.3)} .36 .34 .12 .035 22 normal")
            rows.extend(reveal)
        mc(f"{directory}/{n}",*rows)
