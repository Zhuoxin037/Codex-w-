"""Group the training rack by profession and rarity and add a practice Overlimit bench."""

from collections import defaultdict
import json
from pathlib import Path
import re

from architecture import Build
from floor_upgrade import text, write
from forest_economy import button, literal, say
from lobby_expansion import JOBS, LOBBY, PRACTICING, PREVIEW, TRAINING_DIM
from training_world import NS, STORE, sign

RARITIES = ("常器", "异器", "精器", "秘器", "禁器")
COLORS = ("white", "gray", "aqua", "gold", "red")
BENCH = "275.5 78 38.5"
BENCH_TAG = "sd.training_ol_touch"
CATALOG = LOBBY+"practice/catalog/"


def stage(world):
    root=Path(world)/"datapacks"
    f=root/"zz_sweetdream_floor/data/sweetdream_floor/function"
    base=root/"sweetdream/data/sweetdream/function"

    def mc(name,*rows):
        write(f/f"{name}.mcfunction","\n".join(rows))

    training_catalog(mc,f)
    overlimit(mc,f,base)


def training_catalog(mc,f):
    path=f/"lobby/practice/route.mcfunction"
    route=text(path).splitlines()
    pattern=r'matches (\d+) run return run give @s .*?\bzx:\["([^"]+)"'
    grants={match[2]:int(match[1]) for line in route if (match:=re.search(pattern,line))}
    assert grants, "Training grant IDs missing"
    groups=defaultdict(list)
    for line in text(f/"pool/load.mcfunction").splitlines():
        if " entries append value " not in line:
            continue
        row=json.loads(line.split(" entries append value ",1)[1])
        if row["id"] in grants and row.get("name"):
            group="offhand" if row["category"]=="tool" else str(row["job"])
            groups[group].append(row)
    assert {row["id"] for group in groups.values() for row in group}==set(grants)
    assert set(groups)<=({"offhand"} | {str(i) for i in range(len(JOBS))})

    mc("lobby/practice/menu",f"tag @s add {PRACTICING}",say("训练场 · 装备架","aqua"),
       "tellraw @s "+literal(menu_buttons((("通用装备",110,"white"),("职业装备",111,"light_purple"),("副手",112,"aqua")))),
       "tellraw @s "+literal(menu_buttons(tuple((job,180+i,"gray") for i,job in enumerate(JOBS)))),
       "tellraw @s "+literal(menu_buttons((("补充生命与魔力",101,"green"),("清空训练装备",102,"gray")))))
    mc("lobby/practice/catalog/jobs",say("职业装备","light_purple"),
       "tellraw @s "+literal(menu_buttons(tuple((name,113+i,"white") for i,name in enumerate(JOBS[1:],1)
                                                 if groups[str(i)]))),
       "tellraw @s "+literal(button("装备架",100,"gray")))
    dispatch=[f"execute if score #input sd.floor matches 111 run return run function {CATALOG}jobs"]
    page_id=120
    for group,title,menu_code,back_code in (
        ("0","通用装备",110,100),
        *((str(i),name,113+i,111) for i,name in enumerate(JOBS[1:],1)),
        ("offhand","副手",112,100),
    ):
        if not groups[group]:
            continue
        menu=[]
        tiers=((0,groups[group]),) if group=="offhand" else tuple(
            (tier,[row for row in groups[group] if row["tier"]==tier]) for tier in range(1,6))
        for tier,pool in tiers:
            if not pool:
                continue
            rarity=RARITIES[tier-1] if tier else title
            color=COLORS[tier-1] if tier else "aqua"
            menu.append((rarity,page_id,color))
            pool.sort(key=lambda row: (row["category"],row["name"]))
            pages=(len(pool)+7)//8
            for index in range(pages):
                heading=f"{title} · {rarity}" if tier else title
                nav=[("稀有度",menu_code,"gray")] if tier else [("装备架",100,"gray")]
                if index:
                    nav.append(("上一页",page_id-1,"aqua"))
                if index+1<pages:
                    nav.append(("下一页",page_id+1,"aqua"))
                mc(f"lobby/practice/pages/{page_id}",
                   say(f"{heading}  {index+1}/{pages}","aqua"),say("悬停预览 · 点击领取"),
                   *preview_rows(pool[index*8:index*8+8],grants,color),
                   "tellraw @s "+literal(menu_buttons(nav)))
                dispatch.append(f"execute if score #input sd.floor matches {page_id} run return run function {LOBBY}practice/pages/{page_id}")
                page_id+=1
        if group=="offhand":
            target=f"{LOBBY}practice/pages/{menu[0][1]}"
        else:
            target=CATALOG+group
            mc(f"lobby/practice/catalog/{group}",say(title,"aqua"),
               "tellraw @s "+literal(menu_buttons(menu)),
               "tellraw @s "+literal(button("返回",back_code,"gray")))
        dispatch.append(f"execute if score #input sd.floor matches {menu_code} run return run function {target}")
    lines=[line for line in route if f"run return run function {LOBBY}practice/pages/" not in line]
    first_grant=next(i for i,line in enumerate(lines) if "run return run give @s" in line)
    write(path,"\n".join([*lines[:first_grant],*dispatch,*lines[first_grant:]]))


def menu_buttons(options):
    return [element for name,code,color in options for element in (button(name,code,color),{"text":"  "})]


def preview_rows(pool,grants,color):
    for offset in range(0,len(pool),4):
        yield f"data modify storage {PREVIEW} row set value []"
        for row in pool[offset:offset+4]:
            yield f"data modify storage {PREVIEW} label set value {literal(button(row['name'],grants[row['id']],color))}"
            yield f"function {LOBBY}practice/preview/add {{id:{literal(row['id'])}}}"
        yield f"function {LOBBY}practice/preview/show with storage {PREVIEW}"


def overlimit(mc,f,base):
    build=Build()
    build.box((273,77,36),(278,77,41),"polished_deepslate")
    build.box((275,77,38),(276,77,39),"waxed_oxidized_cut_copper")
    build.set(275,78,40,"smithing_table")
    build.set(276,78,40,"blast_furnace[facing=north]")
    for x in (273,278):
        build.box((x,78,40),(x,81,40),"stripped_dark_oak_log")
        build.set(x,78,38,"polished_deepslate_wall")
        build.set(x,79,38,"lantern")
    build.box((273,81,39),(278,81,41),"spruce_slab[type=top]")
    build.set(274,78,40,"anvil[facing=west]")
    mc("training/overlimit/build",*build.lines,
       sign((276,80.15,39),"超限台","副手放装备 · 潜行超限","sd.training_overlimit","light_purple"),
       f"data modify storage {STORE} overlimit_spot set value 1b")
    file=f/"training/player_tick.mcfunction"
    write(file,text(file)+f"\nfunction {NS}overlimit/tick")
    mc("training/overlimit/tick",
       f"execute unless data storage {STORE} {{overlimit_spot:1b}} if loaded 275 78 39 run function {NS}overlimit/build",
       f"execute positioned {BENCH} unless entity @s[distance=..1.6] run tag @s remove {BENCH_TAG}",
       f"execute unless predicate sweetdream:is_sneaking run tag @s remove {BENCH_TAG}",
       f"execute positioned {BENCH} if entity @s[tag=!{BENCH_TAG},distance=..1.6] "
       f"if predicate sweetdream:is_sneaking at @s run function {NS}overlimit/use")
    items=sorted(file.stem for file in (base/"overlimit/apply").glob("*.mcfunction"))
    assert items
    mc("training/overlimit/use", f"tag @s add {BENCH_TAG}",
       *(f'execute if items entity @s weapon.offhand *[minecraft:custom_data~{{sd_training:1b,zx:["{key}"]}}] '
         f'run return run function {NS}overlimit/apply {{id:"{key}"}}' for key in items),
       say("副手放入可超限的装备。"))
    mc("training/overlimit/apply",
       '$data modify storage zx:work st set value {kind:"overlimit",id:"",cat:"",cat2:"",of:"$(id)"}',
       "function sweetdream:station/api/apply",
       'execute if data storage zx:out r{ok:1b} run playsound minecraft:block.smithing_table.use master @s ~ ~ ~ 0.7 1.1',
       'execute if data storage zx:out r{ok:1b} run return run '+say("已超限","green"),
       'execute if data storage zx:out r{reason:"already"} run return run '+say("已超限。"),
       say("这件装备暂无超限。"))
