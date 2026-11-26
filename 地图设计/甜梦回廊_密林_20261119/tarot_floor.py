"""One shared card per floor. The overlay is exclusive to the Fallen Dream save."""
from pathlib import Path
from tempfile import mkdtemp
import json
import math
import shutil
import sys

from floor_route_map import DIMS
from migrate_world_resources import WORLD, ROOT, MASTER, ENABLED
from tarot_art import COLORS, card_assets


PACK = "zzzzzzzz_fallendream_tarot"
F = "sweetdream_floor:"
T = "fallentarot:"
R = F+"run"
S = T+"floor"
M = "ft.math"
ACTIVE = "tag=sd.floor_run,tag=zx.rg_active,tag=!sd.rejoin_pending,scores={sd.floor_death=0}"
PLAYERS = f"@a[{ACTIVE},distance=0..]"
CARDS = {
    1: ("fool","愚人","魔耗浮动 ±60%　敌方攻击浮动 ±30%","魔耗越低，敌方攻击越强"),
    2: ("lovers","恋人","5 格内相伴 2 秒，玩家回 4、敌人回 8 生命，每场最多两次",
        "拉开超过 8 格持续 2 秒，血量比例较低者回血，玩家 6／敌人 12，每场最多两次"),
    3: ("tower","高塔","击破石柱，倒塌对敌 16 伤害，对友 9 伤害","击破石柱，升起 8 秒掩体"),
}
SCENE_END=69
SCENE_CENTER="2.75 82.56 72.5"
SCENE_PLAYING=f"if score #scene {M} matches 0..{SCENE_END-1}"


def j(value):
    return json.dumps(value,ensure_ascii=False,separators=(",",":"))


class Overlay:
    def __init__(self, root, source):
        self.root=root/"datapacks"/PACK
        self.source=source
        self.packs=sorted((p for p in source.iterdir() if p.is_dir() and p.name!=PACK),reverse=True)

    def asset(self,name,value):
        target=self.root/name
        target.parent.mkdir(parents=True,exist_ok=True)
        target.write_text(value.rstrip()+"\n",encoding="utf8")

    @staticmethod
    def path(name):
        ns,sub=name.split(":",1)
        return f"data/{ns}/function/{sub}.mcfunction"

    def read(self,name):
        rel=self.path(name)
        return next((pack/rel).read_text(encoding="utf8").splitlines() for pack in self.packs if (pack/rel).is_file())

    def mc(self,name,*rows):
        self.asset(self.path(name),"\n".join(rows))

    def ft(self,name,*rows):
        self.mc(T+name,*rows)

    def around(self,name,needle,*rows,after=False):
        old=self.read(name)
        matching=[i for i,line in enumerate(old) if not line.startswith("#") and needle in line]
        if len(matching)!=1:
            raise ValueError((name,needle,matching))
        at=matching[0]+int(after)
        self.mc(name,*old[:at],*rows,*old[at:])


def stage(world,source):
    p=Overlay(world,source)
    p.asset("pack.mcmeta",j({"pack":{"pack_format":71,"description":"坠梦 · 楼层塔罗牌"}}))
    for event in ("load","tick"):
        p.asset(f"data/minecraft/tags/function/{event}.json",j({"values":[T+event]}))
    p.ft("load",*(f"scoreboard objectives add {name} dummy" for name in
        (M,"ft.room","ft.rev","ft.mana","ft.vote","ft.serial","ft.cap","ft.age")),
        f"scoreboard players add #rev {M} 0",f"scoreboard players set #100 {M} 100")
    lifecycle(p)
    reveal(p)
    fool(p)
    from tarot_combat import combat
    combat(p)
    from tarot_tools import tools
    tools(p)
    return p.root


def lifecycle(p):
    from tarot_route_fix import map_roads, entry_lights

    for name,needle in (("run/start","add #serial sd.floor 1"),("next/wait","floor set value 2")):
        p.around(F+name,needle,f"function {T}choose_floor",after=True)
    p.ft("choose_floor",
        f"data remove storage {S} vote",
        f"data remove storage {S} loot",
        f"data modify storage {S} rooms set value {{}}",
        f"data remove storage {S} card",
        f"execute store result storage {S} run int 1 run scoreboard players get #serial sd.floor",
        f"data modify storage {S} level set from storage {R} floor",
        f"scoreboard players set #scene {M} -1",
        f"scoreboard players set #attack {M} 100")
    p.ft("set_card",
        f"scoreboard players add #rev {M} 1",
        f"execute store result storage {S} card.id int 1 run scoreboard players get #card {M}",
        f"execute store result storage {S} card.reverse byte 1 run scoreboard players get #reverse {M}",
        *(f"execute if score #card {M} matches {i} run function {T}card/{key}" for i,(key,*_) in CARDS.items()))
    for _,(key,name,up,down) in CARDS.items():
        p.ft(f"card/{key}", f'data modify storage {S} card merge value {{key:"{key}",name:"{name}"}}',
            *(f'execute if score #reverse {M} matches {rev} run data modify storage {S} card merge value '
              f'{{side:"{side}",detail:"{detail}",color:"{color}"}}' for rev,side,detail,color in
              ((0,"正位",up,COLORS[key]),(1,"逆位",down,"#d9a9f4"))))
    p.ft("tick",
        f"execute as @a[scores={{ft.cap=1..}}] run function {T}love/restore_previous",
        f"execute unless entity @a[tag=sd.floor_run] run return run function {T}idle",
        *(f"execute {'if' if i else 'unless'} data storage {R} {{floor:2}} in {dim} run function {T}dimension"
          for i,dim in enumerate(DIMS)))
    p.ft("idle",
        f"execute {SCENE_PLAYING} run scoreboard players set #scene {M} {SCENE_END}",
        *(f"execute in {dim} if entity @e[tag=ft.scene,distance=0..] run kill @e[tag=ft.scene,distance=0..]" for dim in DIMS),
        *(f"execute in {dim} if entity @e[tag=ft.tower,distance=0..] run function {T}combat/clear" for dim in DIMS))
    p.ft("dimension",
        f"execute {SCENE_PLAYING} positioned {SCENE_CENTER} run function {T}scene/tick",
        f"execute if data storage {S} vote run function {T}tool/tick",
        f"execute if score #phase sd.floor matches 2 if data storage {R} encounter run return run function {T}combat/tick",
        f"execute if score #armed {M} matches 1 run function {T}combat/clear")
    arrive=p.read(F+"run/arrive")
    p.mc(F+"run/arrive",*arrive,
         f"execute if score #scene {M} matches -1 run return run function {T}scene/start",
         f"execute if score #scene {M} matches {SCENE_END} run function {T}scene/report")
    p.ft("info",
         '$tellraw @s [{text:"◇  $(name) · $(side)",color:"$(color)",bold:true,hover_event:{action:"show_text",value:{text:"$(detail)",color:"white"}}}]')
    for view,x,y,z,size in (("normal",.97,1.30,2.7472,.29),("compact",.71,.95,1.8268,.21),("narrow",.53,.71,1.3002,.16)):
        path=f"fallenroute:floor/board/{view}"
        rows=map_roads(p.read(path),view)
        at=next(i for i,row in enumerate(rows) if row=="function fallenroute:floor/stamp")
        rows.insert(at,f"execute if data storage {S} card.key run function {T}map/{view} with storage {S} card")
        p.mc(path,*rows)
        p.ft("map/"+view,
             f'$execute positioned ^{x} ^{y} ^{z} run summon minecraft:text_display ~ ~ ~ '
             '{Tags:["rgp.ui","rgp.new","rd.rotate"],billboard:"fixed",background:0,brightness:{block:15,sky:15},'
             'text:{text:"$(name) · $(side)",color:"#633a30",bold:true},'
             f'transformation:{{translation:[0f,0f,0f],scale:[{size}f,{size}f,{size}f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}}}')
    entry_lights(p)


def reveal(p):
    wait="正在揭牌…"
    for name in (F+"routes/player","fallenroute:floor/travel"):
        p.mc(name,f"execute {SCENE_PLAYING} run return 0",*p.read(name))
    p.mc("fallenroute:floor/available",
         f'execute if entity @s[{ACTIVE}] {SCENE_PLAYING} run return fail',
         *p.read("fallenroute:floor/available"))
    p.ft("scene/start",
        f"execute store result score #card {M} run random value 1..3 fallentarot:cards",
        f"execute store result score #reverse {M} run random value 0..1 fallentarot:cards",
        f"function {T}set_card",
        f"scoreboard players set #scene {M} 0",
        f"execute positioned {SCENE_CENTER} run function {T}scene/build",
        f"title {PLAYERS} clear",
        f'title {PLAYERS} actionbar {{text:"{wait}",color:"gray"}}',
        f'playsound minecraft:block.enchantment_table.use master {PLAYERS} ~ ~ ~ .55 .65')
    p.ft("scene/report",
        f"execute if data storage {S} card.key run function {T}info with storage {S} card",
        f"execute if score @s zx.rg_room matches 10 run function {T}tool/menu")
    p.ft("scene/build",
        'kill @e[tag=ft.scene,distance=..4]',
        *(f'summon minecraft:item_display ~ ~ ~ {{Tags:["ft.scene","ft.card{i}"],brightness:{{block:15,sky:15}},'
          'item:{id:"minecraft:paper",count:1,components:{"minecraft:item_model":"fallentarot:back"}},'
          'transformation:{translation:[0f,0f,0f],scale:[.01f,.01f,1f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}'
          for i in range(3)))
    p.ft("scene/tick",
        f"scoreboard players add #scene {M} 1",
        *(f"execute if score #scene {M} matches {i} run function {T}scene/frame/{i}" for i in range(1,SCENE_END+1,2)))
    for tick in range(1,SCENE_END+1,2):
        rows=[]
        if tick==43:
            rows+=['kill @e[tag=ft.scene,tag=!ft.card0,distance=..4]']
        if tick==45:
            rows += [f"function {T}scene/face with storage {S} card"]
        if tick==53:
            rows += [f"function {T}scene/title with storage {S} card",
                     f"particle minecraft:end_rod ~ ~ ~ .16 .7 .45 .025 10 force {PLAYERS}"]
        if tick==SCENE_END:
            p.ft(f"scene/frame/{tick}","kill @e[tag=ft.scene,distance=..4]",
                 f"execute as {PLAYERS} run function {T}scene/report")
            continue
        for i in range(3 if tick<43 else 1):
            scale=min(1,.04+tick/12)
            if i==0:
                converge=max(0,min(1,(tick-27)/12))
                if tick<39:
                    theta=(tick/39)*math.tau*1.7
                    x=.62*math.sin(theta)*(1-converge)
                    z=.16*math.cos(theta)*(1-converge)
                    y=.10*math.sin(theta*2)*(1-converge)
                    rot=.28*math.sin(theta)*(1-converge)
                else:
                    x=y=z=0
                    rot=(math.pi/2)*max(0,1-abs(tick-43)/8)
            else:
                theta=(tick/39)*math.tau*1.7+i*math.tau/3
                x=.60*math.sin(theta)
                z=.16*math.cos(theta)
                y=.13*math.cos(theta+1)
                rot=.36*math.sin(theta)
                scale *= .72*max(.01,min(1,(42-tick-i*3)/7))
            ent=f"@e[tag=ft.card{i},distance=..4,limit=1]"
            rows.append(f"tp {ent} ~{z:.4f} ~{y:.4f} ~{-x:.4f}")
            rot+=math.pi/2
            for rev in range(2 if i==0 and tick>=43 else 1):
                roll=math.pi*max(0,min(1,(tick-43)/8))*rev
                q=(math.sin(rot/2)*math.sin(roll/2),math.sin(rot/2)*math.cos(roll/2),
                   math.cos(rot/2)*math.sin(roll/2),math.cos(rot/2)*math.cos(roll/2))
                left=",".join(f"{v:.5f}f" for v in q)
                prefix=f"execute if score #reverse {M} matches {rev} run " if i==0 and tick>=43 else ""
                rows.append(f"{prefix}data merge entity {ent} "
                    f"{{start_interpolation:0,interpolation_duration:2,teleport_duration:2,"
                    f"transformation:{{scale:[{scale*.98:.4f}f,{scale*1.47:.4f}f,1f],left_rotation:[{left}]}}}}")
        p.ft(f"scene/frame/{tick}",*rows)
    p.ft("scene/face",
        '$data modify entity @e[tag=ft.card0,distance=..4,limit=1] item.components."minecraft:item_model" set value "fallentarot:$(key)"')
    p.ft("scene/title",
        '$summon minecraft:text_display ~ ~-.94 ~ {Tags:["ft.scene"],billboard:"center",background:0,shadow:1b,brightness:{block:15,sky:15},'
        'text:{text:"$(name) · $(side)",color:"$(color)",bold:true},'
        'transformation:{translation:[0f,0f,0f],scale:[.50f,.50f,.50f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}',
        f'$title {PLAYERS} actionbar {{text:"$(detail)",color:"$(color)"}}',
        f"playsound minecraft:block.amethyst_block.chime master {PLAYERS} ~ ~ ~ .85 .8")


def fool(p):
    p.around("fallendream:rogue/map/visit_pick","run function sweetdream_floor:room/check_lock",
        f"$execute if score @s zx.rg_room matches $(cell) if entity @s[{ACTIVE}] run function {T}fool/visit {{cell:$(cell)}}")
    p.ft("fool/visit",
        f"execute unless data storage {S} card{{id:1}} run return run scoreboard players set @s ft.mana 100",
        "$execute if score @s ft.room matches $(cell) if score @s ft.rev = #rev ft.math run return 0",
        "$scoreboard players set @s ft.room $(cell)",
        f"scoreboard players operation @s ft.rev = #rev {M}",
        f"$execute unless data storage {S} rooms.c$(cell) run function {T}fool/roll {{cell:$(cell)}}",
        f"$function {T}fool/visit_apply with storage {S} rooms.c$(cell)")
    p.ft("fool/roll",
        f"$data modify storage {S} rooms.c$(cell) set value {{}}",
        f"$execute store result storage {S} rooms.c$(cell).mana int 1 run random value -60..60 fallentarot:fool",
        f"$execute store result storage {S} rooms.c$(cell).atk int 1 run random value -30..30 fallentarot:fool")
    p.ft("fool/visit_apply",
        "$scoreboard players set @s ft.mana $(mana)",
        "$scoreboard players set #new_attack ft.math $(atk)",
        f"function {T}fool/rate",
        'tellraw @s [{text:"愚人 · 魔耗 ",color:"#dcb981"},{score:{name:"@s",objective:"ft.mana"}},'
        '{text:"%　敌攻 ",color:"#dcb981"},{score:{name:"#new_attack",objective:"ft.math"}},{text:"%"}]')
    p.ft("fool/rate",
        f"execute if score #reverse {M} matches 1 run scoreboard players operation #new_attack {M} = @s ft.mana",
        f"execute if score #reverse {M} matches 1 run scoreboard players set #neg_two {M} -2",
        f"execute if score #reverse {M} matches 1 run scoreboard players operation #new_attack {M} /= #neg_two {M}",
        "scoreboard players add @s ft.mana 100",
        f"scoreboard players add #new_attack {M} 100")
    p.ft("fool/battle",
        f"scoreboard players set #attack {M} 100",
        f"$execute if data storage {S} card{{id:1}} if data storage {S} rooms.c$(cell) "
        f"run function {T}fool/battle_apply with storage {S} rooms.c$(cell)")
    p.ft("fool/battle_apply",
        "$scoreboard players set #attack ft.math $(atk)",
        f"$execute if score #reverse {M} matches 1 run function {T}fool/reverse_attack {{mana:$(mana)}}",
        f"scoreboard players add #attack {M} 100")
    p.ft("fool/reverse_attack","$scoreboard players set #attack ft.math $(mana)",
        f"scoreboard players set #neg_two {M} -2",f"scoreboard players operation #attack {M} /= #neg_two {M}")
    check="execute if score #cur manacore.math < #need manacore.math"
    cost_hook=(f"execute if score #need manacore.math matches 1.. if data storage {S} card{{id:1}} "
               f"unless data storage zx:work mp_p{{passive:1b}} if entity @s[{ACTIVE}] if score @s ft.rev = #rev {M} "
               f"if score @s ft.room = @s zx.rg_room run function {T}fool/cost")
    p.around("manacore:internal/skill/check_mana",check,cost_hook)
    p.around("manacore:internal/mana/consume","set #ok manacore.math 0",cost_hook)
    p.ft("fool/cost",
        "scoreboard players set #ft_cap manacore.math 2147483647",
        "scoreboard players operation #ft_cap manacore.math /= @s ft.mana",
        "scoreboard players operation #need manacore.math < #ft_cap manacore.math",
        "scoreboard players operation #need manacore.math *= @s ft.mana",
        f"scoreboard players operation #need manacore.math /= #100 {M}")


def install(built,assets):
    world=WORLD.resolve(strict=True)
    packs=(world/"datapacks").resolve(strict=True)
    dest=packs/PACK
    if packs.parent!=world or (dest.exists() and dest.resolve()!=dest) or (world/"resources.zip").exists():
        raise RuntimeError("Unexpected save layout")
    for src in assets:
        target=ENABLED/src.relative_to(MASTER)
        target.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(src,target)
        assert target.read_bytes()==src.read_bytes(),target
    temp=Path(mkdtemp(prefix=".tarot-",dir=world))
    ready=temp/PACK
    shutil.copytree(built,ready)
    for file in built.rglob("*"):
        if file.is_file():
            assert (ready/file.relative_to(built)).read_bytes()==file.read_bytes(),file
    backup=None
    if dest.exists():
        backup=Path(mkdtemp(prefix="tarot_backup_",dir=ROOT/".workbuddy")).resolve()/PACK
        if not backup.is_relative_to(ROOT.resolve()):
            raise RuntimeError("Unexpected backup location")
        dest.rename(backup)
    try:
        ready.rename(dest)
    except OSError:
        if backup is not None:
            backup.rename(dest)
        raise
    temp.rmdir()
    print(f"Installed {len(list(dest.rglob('*.mcfunction')))} tarot functions and {len(assets)} art assets.")


if __name__=="__main__":
    path=Path(sys.argv[1])
    built=stage(path,WORLD/"datapacks")
    art=card_assets(MASTER)
    if "--install" in sys.argv:
        install(built,art)
