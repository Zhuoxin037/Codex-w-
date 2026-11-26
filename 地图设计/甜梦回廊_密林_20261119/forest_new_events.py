"""Three new scenes and their one-use Forest events."""

from pathlib import Path

from architecture import Build
from floor_upgrade import text, write
from forest_economy import FN, RUN, button, literal, say
from forest_events import EVENT
from forest_flow import PARTY

SERVICES = {
    "merchant": ("行商", "merchant"), "forge": ("铸造坊", "forge_used"),
    "astrology": ("占星室", ""), "blackmarket": ("黑市", "black"),
    "safe": ("安全角落", "safe_used"), "gamble": ("赌博房", "gamble_used"),
    "rental": ("租借商人", "rental_used"),
}
NEW_EVENTS = ("clothesline", "unfinished_map", "unattended_counter")
TARGET_CODE = 200
PACK = "fallendream:rogue/"
COAT_END = 2147483647


def stage(world):
    data = Path(world)/"datapacks/zz_sweetdream_floor/data"
    functions = data/"sweetdream_floor/function"

    def mc(name, *rows):
        write(functions/f"{name}.mcfunction", "\n".join(rows))

    def ev(name, *rows):
        mc(f"room/event/{name}", *rows)

    def before(path, anchor, rows):
        p = functions/f"{path}.mcfunction"
        body = text(p)
        if rows[0] not in body:
            if anchor not in body:
                raise ValueError(f"Missing Forest event hook in {p}")
            write(p, body.replace(anchor, "\n".join(rows)+"\n"+anchor, 1))

    def caption(name, description):
        return say("\n◇  "+name, "green"), say(description)

    def option(code,label,hint=""):
        return "tellraw @s "+literal([{"text":"    "},button(label,code),{"text":"  "+hint,"color":"gray"}])

    pool = functions/"generation/reset_pool.mcfunction"
    if "9,10,11" not in text(pool):
        write(pool, text(pool).replace("[0,1,2,3,4,5,6,7,8]", "[0,1,2,3,4,5,6,7,8,9,10,11]", 1))
    for folder, prefix, tail in (("info", "", f"function {EVENT}traveler"),
                                 ("service", "choose_", "execute unless score #input sd.floor matches 20..21 run return 0")):
        before(f"room/{folder}/event", tail,
               [f"execute if data storage {RUN} inspected{{variant:{i}}} run return run function {EVENT}{prefix}{name}"
                for i,name in enumerate(NEW_EVENTS, 9)])
    before("run/route", "execute if score #input sd.floor matches 20..22 run function",
           [f"execute if score #input sd.floor matches {TARGET_CODE}..{TARGET_CODE+24} run return run function {EVENT}new_route",
            f"execute if score #input sd.floor matches 27..28 run return run function {EVENT}new_route"])
    ev("new_route", f"function {FN}room/read",
       f'execute unless data storage {RUN} inspected{{kind:"event"}} run return 0',
       f"function {FN}room/select_go with storage {RUN} inspected")
    for i,name in enumerate(NEW_EVENTS, 9):
        scene = Build(relative=True)
        SCENES[name](scene)
        write(data/f"fallendream/function/rogue/detail/event_{i}.mcfunction", "\n".join(scene.lines))

    ev("clothesline", *caption("晾衣绳", "两棵树之间拉着一根晾衣绳。水顺着绳子往下滴，外套摸起来却是干的。"),
       option(20,"穿上外套","下场战斗获得 4 点吸收"), option(21,"解下银扣","获得 2 梦屑"))
    ev("choose_clothesline", "execute unless score #input sd.floor matches 20..21 run return 0", f"function {EVENT}accept",
       f"execute if score #input sd.floor matches 20 run return run function {EVENT}save_coat",
       "scoreboard players add #lumen sd.floor 2", say("你解下了银扣。","green"))
    ev("save_coat", "tag @s add sd.event_coat", say("你穿上了外套。","green"))
    before("combat/begin", f"function {FN}combat/arena",
           [f"execute as {PARTY} if entity @s[tag=sd.event_coat] run function {EVENT}coat_begin"])
    before("combat/win", f"function {FN}flow/locate_choice",
           [f"execute as {PARTY} if entity @s[tag=sd.event_coat_active] run function {EVENT}coat_finish"])
    before("room/event/reset", "scoreboard players set @s sd.event_time 0",
           [f"execute if entity @s[tag=sd.event_coat_active] run function {EVENT}coat_finish", "tag @s remove sd.event_coat"])
    ev("coat_begin", "tag @s remove sd.event_coat", "tag @s add sd.event_coat_active",
       "scoreboard players set #s2_g_v zx.meta 4000",
       f"scoreboard players set #s2_g_t zx.meta {COAT_END}",
       "scoreboard players operation #s2_g_t zx.meta -= #now manacore.meta",
       "function fallendream:batch21/shield/grant")
    ev("coat_finish", "tag @s remove sd.event_coat_active", "function fallendream:lib/uuid",
       f"function {EVENT}coat_expire with storage zx:data self")
    ev("coat_expire",
       f'$execute unless data storage zx:b21 p."$(uuid)".shields[{{end:{COAT_END}}}] run return 0',
       f'$execute store result storage zx:b21 p."$(uuid)".shields[{{end:{COAT_END}}}].end int 1 run scoreboard players get #now manacore.meta',
       "function fallendream:batch21/shield/tick")
    ev("coat_apply", "$attribute @s minecraft:max_absorption modifier add fallendream:thp_cap $(mod) add_value",
       "$effect give @s minecraft:absorption infinite $(amp) true", "tag @s add zx.thp_on")
    shield = Path("fallendream/function/batch21/shield/set.mcfunction")
    primary = data.parents[1]/"fallendream/data"/shield
    original = "function fallendream:lib/thp/apply with storage zx:work s2_abs_apply"
    match = f"data storage zx:work s2_keep[{{end:{COAT_END}}}]"
    body = text(primary)
    if body.count(original)!=1:
        raise ValueError("Expected the shared absorption applicator")
    write(data/shield, body.replace(original, "\n".join((
        f"execute unless {match} if score @s zx.thp_end matches {COAT_END} run scoreboard players set @s zx.thp_end 0",
        f"execute if {match} run function {EVENT}coat_apply with storage zx:work s2_abs_apply",
        f"execute if {match} run scoreboard players set @s zx.thp_end {COAT_END}",
        f"execute unless {match} run {original}",
    ))))

    route_map(ev, caption, option)
    ev("unattended_counter", *caption("无人的柜台", "树洞口装了块齐腰高的木板，板上钉着一张「请当面点清」。柜台后面是空的。"),
       f"execute if data storage {RUN} draw_stash[0] run "+option(20,"取回","打开最早寄存的抽取"),
       f"execute if data storage {RUN} draw_stash[0] run "+option(21,"折现","最早寄存的抽取换 3 梦屑"),
       option(28,"偷取","抽取装备，有一半概率失去队伍现有梦屑的一半"), option(27,"离开"))
    ev("choose_unattended_counter", "execute unless score #input sd.floor matches 20..21 unless score #input sd.floor matches 27..28 run return 0",
       f"execute if score #input sd.floor matches 20..21 unless data storage {RUN} draw_stash[0] run return 0",
       f"function {EVENT}accept", "execute if score #input sd.floor matches 27 run return 0",
       f"execute if score #input sd.floor matches 20 run return run function {EVENT}counter_reopen",
       f"execute if score #input sd.floor matches 21 run return run function {EVENT}counter_cash",
       "execute store result score #counter_flip sd.floor run random value 0..1 sweetdream:rogue",
       f"execute if score #counter_flip sd.floor matches 1 run function {EVENT}counter_loss",
       f'data modify storage {RUN} draw_source set value "normal"', f"function {FN}reward/ask")
    ev("counter_reopen", f"function {FN}flow/locate_choice", f"function {FN}bank/reopen")
    ev("counter_cash", f"data remove storage {RUN} draw_stash[0]", "scoreboard players add #lumen sd.floor 3",
       say("你从木板底下摸到 3 梦屑。","green"))
    ev("counter_loss", "scoreboard players set #counter_two sd.floor 2",
       "scoreboard players operation #counter_half sd.floor = #lumen sd.floor",
       "scoreboard players operation #counter_half sd.floor /= #counter_two sd.floor",
       "scoreboard players operation #lumen sd.floor -= #counter_half sd.floor",
       say("你刚拿到抽取机会，柜台的抽屉就自己合上了。","yellow"),
       "tellraw @s "+literal([{"text":"失去 ","color":"gray"},{"score":{"name":"#counter_half","objective":"sd.floor"},"color":"gold"},{"text":" 梦屑","color":"gray"}]))


def route_map(ev, caption, option):
    kinds = tuple(SERVICES)
    ev("unfinished_map", *caption("没画完的地图", "石头压着一张没干的地图。纸上的泥脚印，和你刚走过的那段路一模一样。"),
       f"function {EVENT}map_scan", f"execute if data storage {RUN} map_hidden[0] run "+option(20,"看前面的路","揭示附近至多两个房型"),
       f"execute if score #map_returns sd.floor matches 1.. run "+option(21,"沿脚印折回","让一间走过的功能房重新营业"),
       option(27,"离开"))
    ev("choose_unfinished_map", f"function {EVENT}map_scan",
       f"execute if score #input sd.floor matches 20 if data storage {RUN} map_hidden[0] run return run function {EVENT}map_reveal",
       f"execute if score #input sd.floor matches 21 if score #map_returns sd.floor matches 1.. run return run function {EVENT}map_list",
       f"execute if score #input sd.floor matches 27 run return run function {EVENT}accept",
       *(f"execute if score #input sd.floor matches {TARGET_CODE+i} if data storage {RUN} map_targets[{{cell:{i}}}] run return run function {EVENT}map_return with storage zx:rogue floor.cells[{i}]" for i in range(25)))
    ev("map_scan", f"data modify storage {RUN} map_hidden set value []", f"data modify storage {RUN} map_targets set value []",
       "scoreboard players set #map_returns sd.floor 0",
       f"execute store result score #map_origin sd.floor run data get storage {RUN} inspected.cell",
       f"function {EVENT}map_near",
       *(f"execute if data storage zx:rogue floor.cells[{{cell:{i},present:1b,visited:1b,kind:\"{kind}\"}}] run function {EVENT}map_register {{cell:{i},kind:\"{kind}\"}}"
         for i in range(25) for kind in kinds))
    ev("map_register", "$execute if score #map_origin sd.floor matches $(cell) run return 0",
       f'$data modify storage {RUN} map_targets append value {{cell:$(cell),kind:"$(kind)"}}',
       "scoreboard players add #map_returns sd.floor 1")
    ev("map_list", say("请选择要折回的功能房。"),
       *(f'execute if data storage {RUN} map_targets[{{cell:{i},kind:"{kind}"}}] run '+option(TARGET_CODE+i,label)
         for i in range(25) for kind,(label,_) in SERVICES.items()))
    ev("map_return", f"function {EVENT}accept", f"$data remove storage {RUN} rooms[{{cell:$(cell)}}]",
       *(f'$execute if data storage zx:rogue floor.cells[{{cell:$(cell),kind:"{kind}"}}] run data remove storage {RUN} {key}'
         for kind,(_,key) in SERVICES.items() if key),
       '$execute if data storage zx:rogue floor.cells[{cell:$(cell),kind:"astrology"}] run scoreboard players reset @s sd.astro_floor',
       f"$function {FN}room/teleport_cell with storage zx:rogue floor.cells[$(cell)]",
       "scoreboard players set @s sd.lobby_room -1")
    ev("map_reveal", f"function {EVENT}accept", f"function {PACK}map/reveal_cell with storage {RUN} map_hidden[0]",
       f"execute if data storage {RUN} map_hidden[1] run function {PACK}map/reveal_cell with storage {RUN} map_hidden[1]",
       "scoreboard players add #rd_rev zx.meta 1",
       say("地图上多了新的标记。","green"))
    ev("map_near", *(f"execute if score #map_origin sd.floor matches {i} run return run function {EVENT}map_neighbors/{i}" for i in range(25)))
    pairs = [(i,i+1) for i in range(25) if i%5!=4]+[(i,i+5) for i in range(20)]
    adj = [[] for _ in range(25)]
    for edge,(a,b) in enumerate(pairs):
        adj[a].append((edge,b)); adj[b].append((edge,a))
    for i,links in enumerate(adj):
        ev(f"map_neighbors/{i}",
           *(command for edge,center in links for command in (
               f"execute store result score #map_edge sd.floor run data get storage zx:rogue floor.edges[{edge}]",
               f"execute if score #map_edge sd.floor matches 1 run function {EVENT}map_second/{center}")))
        ev(f"map_second/{i}", f"function {EVENT}map_add {{cell:{i}}}",
           *(command for edge,cell in links for command in (
               f"execute store result score #map_edge sd.floor run data get storage zx:rogue floor.edges[{edge}]",
               f"execute if score #map_edge sd.floor matches 1 run function {EVENT}map_add {{cell:{cell}}}")))
    ev("map_add", f"execute if data storage {RUN} map_hidden[1] run return 0",
       "$execute if score #map_origin sd.floor matches $(cell) run return 0",
       f"$execute if data storage {RUN} map_hidden[{{cell:$(cell)}}] run return 0",
       f"$execute if data storage zx:rogue floor.cells[{{cell:$(cell),present:1b,revealed:0b}}] run data modify storage {RUN} map_hidden append value {{cell:$(cell)}}")


def clothesline(b):
    b.box((-11,0,-9),(-5,0,-6),"coarse_dirt")
    for x in (-11,-5):
        b.set(x,0,-8,"mossy_stone_bricks")
        b.box((x,1,-8),(x,4,-8),"spruce_log[axis=y]")
        b.set(x,5,-8,"spruce_slab[type=bottom]")
    b.box((-10,4,-8),(-6,4,-8),"chain[axis=x]")
    for x,wool in ((-10,"light_gray_wool"),(-8,"brown_wool"),(-7,"brown_wool"),(-6,"gray_wool")):
        b.set(x,3,-8,wool)
    b.set(-8,2,-8,"brown_wool")
    b.set(-10,1,-7,"cauldron")
    b.set(-6,1,-9,"barrel[facing=up]")
    b.set(-6,2,-9,"lantern")


def unfinished_map(b):
    b.box((-11,0,-10),(-5,0,-5),"rooted_dirt")
    b.box((-10,0,-9),(-6,0,-6),"mossy_stone_bricks")
    b.set(-10,0,-8,"tuff_brick_stairs[facing=east]")
    b.set(-6,0,-8,"tuff_brick_stairs[facing=west]")
    b.box((-9,1,-9),(-7,1,-9),"mossy_stone_bricks")
    b.set(-8,2,-9,"lantern")
    b.set(-9,1,-8,"spruce_trapdoor[facing=east,open=false,half=bottom]")
    b.set(-8,1,-8,"cartography_table")
    b.set(-8,2,-8,"white_carpet")
    b.set(-7,1,-8,"mossy_cobblestone_slab[type=bottom]")
    b.set(-10,1,-10,"fern")
    b.set(-6,1,-10,"brown_mushroom")


def counter(b):
    b.box((-11,0,-10),(-5,0,-5),"packed_mud")
    b.box((-10,0,-9),(-6,0,-6),"spruce_planks")
    for x in (-10,-6):
        b.box((x,1,-9),(x,4,-9),"dark_oak_wood[axis=y]")
        b.set(x,4,-8,"spruce_stairs[facing=north,half=top]")
    b.box((-10,4,-9),(-6,4,-9),"stripped_spruce_log[axis=x]")
    b.box((-10,3,-10),(-6,4,-10),"dark_oak_wood")
    b.box((-9,2,-9),(-7,3,-9),"dark_oak_planks")
    b.set(-8,2,-8,'spruce_wall_sign[facing=south]{front_text:{messages:[{text:""},{text:"请当面点清"},{text:""},{text:""}]}}')
    b.box((-9,1,-7),(-7,1,-7),"spruce_slab[type=top]")
    b.set(-7,1,-7,"barrel[facing=south]")
    b.set(-7,2,-7,"lantern")
    b.set(-9,2,-7,"flower_pot")
    b.set(-9,1,-6,"spruce_trapdoor[facing=north,open=true,half=bottom]")


SCENES = {"clothesline":clothesline,"unfinished_map":unfinished_map,"unattended_counter":counter}
