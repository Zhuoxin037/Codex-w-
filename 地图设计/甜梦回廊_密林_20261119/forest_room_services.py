"""Complete the Forest room services that still used prototype rewards."""

import re
from pathlib import Path

from floor_upgrade import edit, text, write
from forest_economy import FN, POOL, RUN, button, literal, say


def stage(world):
    dp = Path(world) / "datapacks"
    f = dp / "zz_sweetdream_floor/data/sweetdream_floor/function"
    base = dp / "sweetdream/data/sweetdream/function"

    def mc(name, *lines):
        write(f / f"{name}.mcfunction", "\n".join(lines))

    # These rooms track uses independently of the one-use room/event ledger.
    p = f / "room/announce.mcfunction"
    body = text(p)
    old = "$execute if data storage " + RUN + " rooms["
    write(p, body.replace(old, "".join(
        f'execute if data storage {RUN} inspected{{kind:"{kind}"}} run return run function {FN}room/info/{kind}\n'
        for kind in ("safe", "forge", "gamble", "rental")) + old))
    for name in ("run/start", "next/wait"):
        p = f / f"{name}.mcfunction"
        rows = text(p)
        prefix = [f"data remove storage {RUN} {key}" for key in ("safe_used", "forge_used", "gamble_used", "rental_used")]
        if name == "run/start":
            prefix.append(f"data modify storage {RUN} draw_stash set value []")
        write(p, rows.replace(f"data remove storage {RUN} merchant",
              "\n".join((*prefix, f"data remove storage {RUN} merchant"))))

    rest_and_draws(f, mc)
    forge(f, base, mc)
    gambling(f, mc)
    loan_weapons(f, mc)


def menu(title, *options):
    return (say(title, "green"), *("tellraw @s " + literal(button(*option)) for option in options))


def rest_and_draws(f, mc):
    for path in ("reward/show", "reward/category_menu"):
        p = f / f"{path}.mcfunction"
        write(p, text(p) + f'execute unless data storage {RUN} {{draw_source:"rental"}} run function {FN}bank/menu')
    mc("bank/menu", "tellraw @s " + literal([button("寄存抽取",115,"green"), {"text":"   "},
       button("销毁抽取",116,"gray")]))
    edit(f / "run/route.mcfunction", ("execute if score #input sd.floor matches 38..39",
         f"execute if score #input sd.floor matches 115..116 if score #phase sd.floor matches 3 run return run function {FN}bank/route\n"
         "execute if score #input sd.floor matches 38..39"))
    mc("bank/route", f"execute unless data storage {RUN} draw_source run return 0",
       f"execute if score #input sd.floor matches 116 run return run function {FN}bank/clear",
       f"execute if data storage {RUN} draw_stash[1] run return run " + say("已寄存两次抽取。"),
       f"data modify storage {RUN} bank_ticket set value {{}}",
       f"data modify storage {RUN} bank_ticket.source set from storage {RUN} draw_source",
       f"execute store result storage {RUN} bank_ticket.tier int 1 run scoreboard players get #tier sd.floor",
       f"execute if data storage {RUN} draw_category run data modify storage {RUN} bank_ticket.category set from storage {RUN} draw_category",
       f"execute if data storage {RUN} exact_tier run data modify storage {RUN} bank_ticket.exact set from storage {RUN} exact_tier",
       f"execute if data storage {RUN} offers[0] run data modify storage {RUN} bank_ticket.offers set from storage {RUN} offers",
       f"data modify storage {RUN} draw_stash append from storage {RUN} bank_ticket",
       f"function {FN}bank/clear", say("已寄存。","green"))
    mc("bank/clear", "scoreboard players set #phase sd.floor 1",
       *(f"data remove storage {RUN} {key}" for key in ("offers","exact_tier","draw_category","choosing_category","draw_source")))
    mc("room/info/safe", say("安全角落","green"),
       f"execute unless data storage {RUN} safe_used run tellraw @s " + literal(button("休息 · 补满生命和魔力",20)),
       f"execute if data storage {RUN} draw_stash[0] run tellraw @s " + literal(button("锻造 · 取出寄存抽取",21)))
    mc("room/service/safe", f"execute if score #input sd.floor matches 21 if data storage {RUN} draw_stash[0] run return run function {FN}bank/reopen",
       "execute unless score #input sd.floor matches 20 run return 0",
       f"execute if data storage {RUN} safe_used run return 0",
       f"data modify storage {RUN} safe_used set value 1b", f"function {FN}run/refill", say("休息完毕。","green"))
    mc("bank/reopen", f"data modify storage {RUN} bank_ticket set from storage {RUN} draw_stash[0]",
       f"data remove storage {RUN} draw_stash[0]",
       f"data modify storage {RUN} draw_source set from storage {RUN} bank_ticket.source",
       f"execute if data storage {RUN} bank_ticket.tier store result score #tier sd.floor run data get storage {RUN} bank_ticket.tier",
       f"execute unless data storage {RUN} bank_ticket.offers[0] run return run function {FN}reward/ask",
       "scoreboard players set #phase sd.floor 3",
       f"data modify storage {RUN} offers set from storage {RUN} bank_ticket.offers",
       f"data modify storage {RUN} draw_category set from storage {RUN} bank_ticket.category",
       f"execute if data storage {RUN} bank_ticket.exact run data modify storage {RUN} exact_tier set from storage {RUN} bank_ticket.exact",
       f"function {FN}reward/show")


def forge(f, base, mc):
    defs = re.findall(r'updef\."(\w+)" set value \{([^\n]*)\}', text(base / "upgrade/def/load.mcfunction"))
    alpha = [(key, re.findall(r'\bcat\d*:"([a-z]+)"', data)) for key, data in defs if key.endswith("_a")]
    next_up = [(prev[1], key) for key, data in defs if (prev := re.search(r'\breq:"(\w+)"', data))]
    held = 'if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["%s"]}]'
    mc("room/info/forge", say("铸造坊","green"),
       f"execute unless data storage {RUN} forge_used.alpha run tellraw @s " + literal(button("主手随机匹配的 α · 2 梦屑",20)),
       f"execute unless data storage {RUN} forge_used.promote run tellraw @s " + literal(button("提升主手的一条升级 · 5 梦屑",21)))
    mc("room/service/forge", f"execute if score #input sd.floor matches 20 run return run function {FN}forge/alpha",
       f"execute if score #input sd.floor matches 21 run return run function {FN}forge/promote")
    mc("forge/alpha",
       f"execute if data storage {RUN} forge_used.alpha run return 0",
       "execute unless score #lumen sd.floor matches 2.. run return run " + say("需要 2 梦屑。","yellow"),
       f"data modify storage {RUN} forge_pool set value []",
       *(f'execute {held % kind} unless data storage {RUN} forge_pool[{{id:"{key}"}}] run data modify storage {RUN} forge_pool append value {{id:"{key}"}}'
         for key,categories in alpha for kind in categories),
       f"execute unless data storage {RUN} forge_pool[0] run return run " + say("主手拿着装备。","yellow"),
       f"function {FN}forge/sample",
       f"function {FN}forge/give with storage {RUN} forge_choice",
       f"data modify storage {RUN} forge_used.alpha set value 1b",
       "scoreboard players remove #lumen sd.floor 2")
    mc("forge/sample", f"execute store result score #len sd.floor run data get storage {RUN} forge_pool",
       "scoreboard players remove #len sd.floor 1",
       f"execute store result storage {RUN} draw.max int 1 run scoreboard players get #len sd.floor",
       f"function {FN}reward/random with storage {RUN} draw",
       f"function {FN}forge/pick with storage {RUN} draw")
    mc("forge/pick", f"$data modify storage {RUN} forge_choice set from storage {RUN} forge_pool[$(index)]")
    mc("forge/give", "$function sweetdream:upgrade/item/$(id)")
    mc("forge/promote", f"execute if data storage {RUN} forge_used.promote run return 0",
       "execute unless score #lumen sd.floor matches 5.. run return run " + say("需要 5 梦屑。","yellow"),
       f"data modify storage {RUN} forge_pool set value []",
       *(f'execute if items entity @s weapon.mainhand *[minecraft:custom_data~{{up:["{prev}"]}}] '
         f'run data modify storage {RUN} forge_pool append value {{id:"{key}"}}' for prev,key in next_up),
       f"execute unless data storage {RUN} forge_pool[0] run return run " + say("主手装备需要一条可提升的升级。","yellow"),
       f"function {FN}forge/sample",
       f"execute as @s at @s run function {FN}forge/prepare",
       "execute unless data storage zx:out r{ok:1b} run return run " + say("这件装备无法提升。","yellow"),
       f"data modify storage {RUN} forge_used.promote set value 1b",
       "scoreboard players remove #lumen sd.floor 5", say("已提升一条升级。","green"))
    mc("forge/prepare", 'summon minecraft:armor_stand ~ ~ ~ {Tags:["sd.forge.swap"],Marker:1b,Invisible:1b,NoGravity:1b}',
       "item replace entity @e[tag=sd.forge.swap,distance=..1,limit=1] weapon.offhand from entity @s weapon.offhand",
       "item replace entity @s weapon.offhand from entity @s weapon.mainhand",
       f"function {FN}forge/apply with storage {RUN} forge_choice",
       "item replace entity @s weapon.mainhand from entity @s weapon.offhand",
       "item replace entity @s weapon.offhand from entity @e[tag=sd.forge.swap,distance=..1,limit=1] weapon.offhand",
       "item replace entity @e[tag=sd.forge.swap,distance=..1,limit=1] weapon.offhand with minecraft:air",
       "kill @e[tag=sd.forge.swap,distance=..1,limit=1]")
    mc("forge/apply",
       '$data modify storage zx:work st set value {kind:"upgrade",id:"$(id)",cat:"",cat2:"",cat3:"",cat4:"",of:""}',
       *(f'$execute if data storage zx:config updef."$(id)".{kind} run data modify storage zx:work st.{kind} set from storage zx:config updef."$(id)".{kind}'
         for kind in ("cat","cat2","cat3","cat4")),
       "function sweetdream:station/api/apply")


def gambling(f, mc):
    mc("room/info/gamble", say("赌博房","green"),
       "tellraw @s " + literal(button("转老虎机 · 1 梦屑",20)),
       f"execute unless data storage {RUN} gamble_used run tellraw @s " + literal(button("押注高阶抽取 · 2 梦屑",21)))
    mc("room/service/gamble",
       f"execute if score #input sd.floor matches 20 run return run function {FN}gamble/spin",
       "execute unless score #input sd.floor matches 21 run return 0",
       f"execute if data storage {RUN} gamble_used run return 0",
       "execute unless score #lumen sd.floor matches 2.. run return run " + say("需要 2 梦屑。","yellow"),
       f"data modify storage {RUN} gamble_used set value 1b", "scoreboard players remove #lumen sd.floor 2",
       "execute store result score #gamble sd.floor run random value 1..5 sweetdream:rogue",
       "execute if score #gamble sd.floor matches 1..2 run return run " + say("梦屑落空。","red"),
       "scoreboard players set #tier sd.floor 5", f"function {FN}reward/offer")
    mc("gamble/spin", "execute unless score #lumen sd.floor matches 1.. run return run " + say("需要 1 梦屑。","yellow"),
       "scoreboard players remove #lumen sd.floor 1",
       f"data modify storage {RUN} slot_line set value []",
       *(f"function {FN}gamble/reel {{i:{i}}}" for i in range(3)),
       f"tellraw @s {{nbt:\"slot_line[]\",storage:\"{RUN}\",interpret:true,separator:{{text:\"  │  \",color:\"gray\"}}}}",
       "playsound minecraft:block.note_block.hat master @s ~ ~ ~ .8 1.5",
       "execute unless score #reel0 sd.floor = #reel1 sd.floor run return 0",
       "execute unless score #reel0 sd.floor = #reel2 sd.floor run return 0",
       f"execute if score #reel0 sd.floor matches ..40 run return run function {FN}gamble/lumen",
       f"execute if score #reel0 sd.floor matches ..70 run return run function {FN}room/event/supply",
       f"execute if score #reel0 sd.floor matches ..90 run return run function {FN}gamble/equipment",
       f"function {FN}gamble/offhand")
    row = (("梦屑", "gold", "..40"), ("补给", "green", "41..70"), ("装备", "aqua", "71..90"), ("副手", "light_purple", "91.."))
    mc("gamble/reel", "execute store result score #roll sd.floor run random value 1..100 sweetdream:rogue",
       *(f'$execute if score #roll sd.floor matches {scope} run scoreboard players set #reel$(i) sd.floor {number}'
         for number,(_,_,scope) in zip((40,70,90,100),row)),
       *(f'execute if score #roll sd.floor matches {scope} run data modify storage {RUN} slot_line append value ' +
         literal({"text":name,"color":color}) for name,color,scope in row))
    mc("gamble/lumen", "scoreboard players add #lumen sd.floor 4", say("赢得 4 梦屑。","gold"))
    mc("gamble/equipment", f'data modify storage {RUN} draw_source set value "normal"', f"function {FN}reward/ask")
    mc("gamble/offhand",
       f'data modify storage {RUN} forge_pool set value []',
       f'data modify storage {RUN} forge_pool append from storage {POOL} entries[{{job:0,group:"offhand"}}]',
       f"function {FN}forge/sample",
       f"function {FN}gamble/give with storage {RUN} forge_choice")
    mc("gamble/give", "$function $(signed) {refund:5}")


def loan_weapons(f, mc):
    mc("room/info/rental", say("租借商人","green"),
       f"execute unless data storage {RUN} rental_used run tellraw @s " + literal(button("租借武器 · 下场战斗后焚毁",20)))
    mc("room/service/rental", "execute unless score #input sd.floor matches 20 run return 0",
       f"execute if data storage {RUN} rental_used run return 0",
       f"data modify storage {RUN} forge_pool set value []",
       *(f'data modify storage {RUN} forge_pool append from storage {POOL} entries[{{job:0,group:"weapon",tier:{tier}}}]' for tier in (1,2)),
       f"function {FN}forge/sample", f"function {FN}rental/grant with storage {RUN} forge_choice",
       f"data modify storage {RUN} rental_used set value 1b",
       say("租借武器将在下场战斗结束时焚毁。","green"))
    for item in (f / "market/items").glob("*.mcfunction"):
        body = text(item)
        grant = re.search(r'^\$give @s (.+?)custom_data=\{sd_floor_refund:\$\(refund\),(.+)$', body, re.M)
        if not grant or not re.search(r'"(?:sword|staff|bow|axe)"', grant[2]):
            continue
        mc(f"rental/items/{item.stem}", "give @s " + grant[1] + "custom_data={sd_rental:1b," + grant[2])
    mc("rental/grant", f"$function {FN}rental/items/$(id)")
    predicate = '*[minecraft:custom_data~{sd_rental:1b}]'
    mc("rental/burn", f"clear @s {predicate}",
       *(f"execute if items entity @s enderchest.{i} {predicate} run item replace entity @s enderchest.{i} with minecraft:air" for i in range(27)),
       f"function sweetdream:lib/uuid",
       f"execute if data storage zx:data self{{ok:1b}} run function {FN}rental/burn_queued with storage zx:data self")
    mc("rental/burn_queued",
       '$data remove storage zx:rogue p."$(uuid)".q[{components:{"minecraft:custom_data":{sd_rental:1b}}}]')
    hook = "data remove storage " + RUN + " encounter"
    edit(f / "combat/win.mcfunction", (hook,
        f"execute as @a[tag=sd.floor_run,distance=0..] at @s run function {FN}rental/burn\n"
        'kill @e[type=minecraft:item,distance=0..,nbt={Item:{components:{"minecraft:custom_data":{sd_rental:1b}}}}]\n' + hook))
    edit(f / "room/event/reset.mcfunction", (f"function {FN}astrology/reset",
         f"function {FN}rental/burn\nfunction {FN}astrology/reset"))
    p = f / "combat/count_weapons.mcfunction"
    write(p, text(p) + f"execute store result score #rented sd.floor run clear @s {predicate} 0\n"
          "scoreboard players operation #weapons sd.floor -= #rented sd.floor")
