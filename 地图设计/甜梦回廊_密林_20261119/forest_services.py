"""Connect the Forest's astrology and black-market rooms to real run effects."""

import json
import re
from pathlib import Path

from floor_upgrade import edit, text, write
from forest_economy import FN, POOL, RUN, button, literal, say

TALENTS = {
    1: ("herb", "余药", "每场战斗结束额外恢复 4 点生命。"),
    2: ("scout", "拾荒眼", "精英战胜后，全队多得 1 梦屑。"),
    3: ("reprise", "余潮", "每场战斗结束恢复 20 魔力。"),
    4: ("starlight", "摘星", "普通和精英战后的装备抽取保底精器。"),
    5: ("heart", "林心", "生命上限增加 4 点。"),
}
TALENT_WEIGHTS = {1:70, 2:13, 3:12, 4:3, 5:2}
RETIRED_ECHO = (
    "combat/echo_combo","combat/echo_event","combat/echo_payout","combat/echo_record",
    "astrology/grant_0",
)
RANKS = ("人格", "凡格", "神格")
COLORS = ("white", "aqua", "light_purple")

# Prices are percentages, applied to the cap before deductions from this market.
# Blood and mana can be mixed, with a separate 60% ceiling for each currency.
PRICES = ((12, 18), (8, 12), (10, 15), (14, 21), (16, 24), (12, 18), (18, 27))


def stage(world):
    dp = Path(world) / "datapacks"
    root = dp / "zz_sweetdream_floor/data/sweetdream_floor/function"
    base = dp / "sweetdream/data/sweetdream/function"

    def mc(name, *lines):
        write(root / f"{name}.mcfunction", "\n".join(lines))

    astrology(root, mc)
    market(root, base, mc)


def remove_echo(world):
    """Strip legacy echo paths when building from earlier map releases."""
    packs = Path(world)/"datapacks"
    data = packs/"zz_sweetdream_floor/data"
    root = data/"sweetdream_floor/function"
    for name in RETIRED_ECHO:
        (root/f"{name}.mcfunction").unlink(missing_ok=True)

    for name,retired in (
        ("combat/begin",("sd.astro_echo","#echo ","#echo_total","#echo_combo","echo_marks")),
        ("combat/tick",("combat/echo_payout",)),
        ("astrology/claim",("tag=sd.astro.echo",)),
        ("astrology/list",("tag=sd.astro.echo",)),
    ):
        file = root/f"{name}.mcfunction"
        rows = [line for line in text(file).splitlines() if not any(key in line for key in retired)]
        if name=="astrology/claim":
            rows = [line.replace("{id:1,weight:35}",f"{{id:1,weight:{TALENT_WEIGHTS[1]}}}") for line in rows]
        write(file,"\n".join(rows))
    status = root/"room/status.mcfunction"
    write(status,text(status).replace("tag=!sd.astro.echo,",""))

    load = root/"load.mcfunction"
    rows = [line for line in text(load).splitlines() if "objectives add sd.astro_echo " not in line]
    # Retire state left in older player and world saves.
    for line in (
        "scoreboard objectives remove sd.astro_echo",
        *(f"scoreboard players reset {score} sd.floor" for score in ("#echo","#echo_total","#echo_combo","#per_echo")),
        *(f"data remove storage {RUN} {key}" for key in ("echo","echo_marks")),
    ):
        if line not in rows:
            rows.append(line)
    write(load,"\n".join(rows))
    reset = root/"astrology/reset.mcfunction"
    if "tag @s remove sd.astro.echo" not in text(reset):
        write(reset,text(reset)+"tag @s remove sd.astro.echo")

    relative = Path("fallendream/function/lib/on_consume.mcfunction")
    hook = data/relative
    if hook.exists():
        body = "\n".join(line for line in text(hook).splitlines() if "combat/echo_event" not in line)
        upstream = packs/"fallendream/data"/relative
        if upstream.is_file() and text(upstream).strip()==body.strip():
            hook.unlink()
        else:
            write(hook,body)


def astrology(root, mc):
    offered = "execute if data storage " + RUN + " inspected{kind:\"astrology\"}"
    # Room completion feeds the next floor's 'skipped astrology' rule. Claiming
    # and menu visibility are personal, so one player cannot lock the room for others.
    for filename in ("announce", "select_go"):
        file = root / f"room/{filename}.mcfunction"
        body = text(file)
        gate = body.index("$execute if data storage " + RUN + " rooms[")
        command = "astrology/show" if filename == "announce" else "astrology/claim"
        write(file, body[:gate] + f"{offered} run return run function {FN}{command}\n" + body[gate:])
    mc("room/info/astrology", f"function {FN}astrology/show")
    mc("room/service/astrology", f"function {FN}astrology/claim")
    read_floor = f"execute store result score #astro_floor sd.floor run data get storage {RUN} floor"
    mc("astrology/show", read_floor,
       say("占星室", "light_purple"),
       "execute unless score @s sd.astro_floor = #astro_floor sd.floor run tellraw @s " +
       literal([button("解读星象", 20), {"text": "  随机获得一个本局天赋", "color": "gray"}]),
       f"execute if score @s sd.astro_floor = #astro_floor sd.floor run function {FN}astrology/list")
    mc("astrology/claim", "execute unless score #input sd.floor matches 20 run return 0", read_floor,
       f"execute if score @s sd.astro_floor = #astro_floor sd.floor run return run function {FN}astrology/list",
       f"data modify storage {RUN} astro_pool set value []",
       *(f"execute unless entity @s[tag=sd.astro.{key}] run data modify storage {RUN} astro_pool append value {{id:{i},weight:{TALENT_WEIGHTS[i]}}}"
         for i, (key, *_) in TALENTS.items()),
       f"execute unless data storage {RUN} astro_pool[0] run return 0",
       "scoreboard players set #astro_weight sd.floor 0",
       f"data modify storage {RUN} astro_queue set from storage {RUN} astro_pool",
       f"function {FN}astrology/sum",
       f"execute store result storage {RUN} draw.total int 1 run scoreboard players get #astro_weight sd.floor",
       f"function {FN}reward/random_quality with storage {RUN} draw",
       f"function {FN}astrology/pick with storage {RUN} astro_pool[0]",
       "scoreboard players operation @s sd.astro_floor = #astro_floor sd.floor",
       f"function {FN}astrology/mark with storage {RUN} inspected",
       "playsound minecraft:block.amethyst_block.chime player @s ~ ~ ~ 1 1.2")
    mc("astrology/mark",
       f"$execute unless data storage {RUN} rooms[{{cell:$(cell)}}] run function {FN}room/mark {{cell:$(cell)}}")
    mc("astrology/sum",
       f"function {FN}astrology/add_weight with storage {RUN} astro_queue[0]",
       f"data remove storage {RUN} astro_queue[0]",
       f"execute if data storage {RUN} astro_queue[0] run function {FN}astrology/sum")
    mc("astrology/add_weight", "$scoreboard players add #astro_weight sd.floor $(weight)")
    mc("astrology/pick",
       "$scoreboard players remove #quality sd.floor $(weight)",
       f"$execute if score #quality sd.floor matches ..0 run return run function {FN}astrology/grant_$(id)",
       f"data remove storage {RUN} astro_pool[0]",
       f"execute if data storage {RUN} astro_pool[0] run function {FN}astrology/pick with storage {RUN} astro_pool[0]")
    for i, (key, label, details) in TALENTS.items():
        mc(f"astrology/grant_{i}", f"tag @s add sd.astro.{key}",
           *(("attribute @s minecraft:max_health modifier add sweetdream_floor:astro_heart 4 add_value",)
             if key == "heart" else ()),
           say(f"{RANKS[i//2]} · {label}  {details}", COLORS[i//2]))
    mc("astrology/list",
       *(f"execute if entity @s[tag=sd.astro.{key}] run " + say(f"{RANKS[i//2]} · {label}  {details}", COLORS[i//2])
         for i, (key, label, details) in TALENTS.items()))
    mc("astrology/reset", "scoreboard players reset @s sd.astro_floor",
       "execute if entity @s[tag=sd.astro.heart] run attribute @s minecraft:max_health modifier remove sweetdream_floor:astro_heart",
       *(f"tag @s remove sd.astro.{key}" for key, *_ in TALENTS.values()))
    f = root / "combat/win.mcfunction"
    body = text(f).replace(
        'execute if score #boon sd.floor matches 2 run execute if data storage ' + RUN +
        ' current{ambush_harder:1b} run scoreboard players add #lumen sd.floor 1\n'
        'effect give @s minecraft:instant_health 1 0 true', "")
    party = "@a[tag=sd.floor_run,tag=zx.rg_active,distance=0..,scores={sd.floor_death=0}]"
    aftermath = (
        f'execute if data storage {RUN} current{{kind:"elite"}} if entity ' +
        party.replace("tag=sd.floor_run", "tag=sd.astro.scout,tag=sd.floor_run") +
        " run scoreboard players add #lumen sd.floor 1",
        f'execute as {party} if entity @s[tag=sd.astro.herb,tag=!sd.floor_win_source] run effect give @s minecraft:instant_health 1 0 true',
        f'execute as {party} if entity @s[tag=sd.astro.reprise] run function {FN}run/mana {{value:20.0}}',
    )
    hook = "data remove storage " + RUN + " encounter"
    body = body.replace("effect give @s minecraft:instant_health 1 0 true",
        "execute if entity @s[tag=sd.astro.herb] run effect give @s minecraft:instant_health 1 1 true\n"
        "execute unless entity @s[tag=sd.astro.herb] run effect give @s minecraft:instant_health 1 0 true")
    body = body.replace(hook, hook + "\ntag @s add sd.floor_win_source\n"
                        + "\n".join(aftermath) + "\ntag @s remove sd.floor_win_source")
    write(f, body)
    p = root / "reward/category.mcfunction"
    replace = f'execute if data storage {RUN} {{draw_source:"elite"}} run function {FN}reward/roll_elite'
    edit(p, (replace, replace + "\n" +
             f'execute if entity @s[tag=sd.astro.starlight] if data storage {RUN} {{draw_source:"normal"}} run function {FN}reward/roll_black\n' +
             f'execute if entity @s[tag=sd.astro.starlight] if data storage {RUN} {{draw_source:"elite"}} run function {FN}reward/roll_black'))
    # Show the complete talent list on demand rather than adding a line for each
    # talent to ordinary room/encounter messages.
    p = root / "room/status.mcfunction"
    line, *rest = text(p).splitlines()
    roster = "@s[" + ",".join(f"tag=!sd.astro.{key}" for key, *_ in TALENTS.values()) + "]"
    write(p, "\n".join((line, f"execute unless entity {roster} run tellraw @s " +
          literal(button("本局天赋", 114, "light_purple")), *rest)))
    edit(root / "run/route.mcfunction", ("execute unless score #phase sd.floor matches 1 run return 0",
         f"execute if score #input sd.floor matches 114 if entity @s[tag=zx.rg_active] run return run function {FN}astrology/list\n"
         "execute unless score #phase sd.floor matches 1 run return 0"))
    edit(root / "load.mcfunction", ("scoreboard objectives add sd.floor ",
         "scoreboard objectives add sd.astro_floor dummy\nscoreboard objectives add sd.floor "))
    edit(root / "room/event/reset.mcfunction", ("execute if score @s sd.event_cut",
         f"function {FN}astrology/reset\nexecute if score @s sd.event_cut"))
    p = root / "run/join_party.mcfunction"
    write(p, f"function {FN}astrology/reset\n" + text(p))


def market(root, base, mc):
    for path in ("run/start", "next/wait"):
        edit(root / f"{path}.mcfunction", (f"data remove storage {RUN} merchant",
             f"data remove storage {RUN} black\ndata remove storage {RUN} merchant"))
    edit(root / "run/route.mcfunction", ("execute if score #input sd.floor matches 70..75",
         f"execute if score #input sd.floor matches 100..113 run return run function {FN}black/route\n"
         "execute if score #input sd.floor matches 70..75"))
    mc("room/info/blackmarket", f"function {FN}black/show")
    mc("room/service/blackmarket", f"function {FN}black/show")
    mc("black/route", f"function {FN}room/read",
       f'execute unless data storage {RUN} inspected{{kind:"blackmarket"}} run return 0',
       f"function {FN}black/action with storage {RUN} inspected")
    mc("black/action", '$execute positioned $(x) 81 $(z) unless entity @s[distance=..8] run return run '+
       say("走到黑市摊前再交易。"),
       f"execute unless data storage {RUN} black.stock run function {FN}black/init",
       *(f"execute if score #input sd.floor matches {100+i*2}..{101+i*2} run return run "
         f"function {FN}black/buy with storage {RUN} black.stock[{i}]" for i in range(5)),
       f"execute if score #input sd.floor matches 110..111 run return run function {FN}black/draw",
       f"execute if score #input sd.floor matches 112..113 run return run function {FN}black/stone")
    mc("black/show", f"execute unless data storage {RUN} black.stock run function {FN}black/init", say("黑市", "light_purple"),
       say("上限随本局交易扣除，鼠标悬停可看商品。"),
       *(f"function {FN}black/line with storage {RUN} black.stock[{i}]" for i in range(5)),
       f"execute unless data storage {RUN} black.sold[{{slot:5}}] run " +
       offer("装备抽取 · 保底精器", 110, PRICES[5]),
       f"execute unless data storage {RUN} black.sold[{{slot:6}}] run " +
       offer("主手装备的超限石", 112, PRICES[6]))
    hover = 'hover_event:{action:"show_item",id:"$(preview_id)",count:1,components:$(preview)}'
    mc("black/line", f'$execute if data storage {RUN} black.sold[{{slot:$(slot)}}] run return run tellraw @s '
       '{text:"    $(name) · 售罄",color:"dark_gray"}',
       '$' + offer("$(name)", "$(hp_code)", ("$(hp)", "$(mana)"), "$(mana_code)", hover))

    # B comes from the pack's real upgrade catalog, including its lore.
    beta = []
    for source in sorted((base / "upgrade/item").glob("*_b.mcfunction")):
        grant = next(line for line in text(source).splitlines() if line.startswith("give @s "))
        name = re.search(r'item_name=(?:\{\s*"?text"?\s*:\s*)?("(?:[^"\\]|\\.)*")', grant)
        identifier = source.stem
        beta.append({"id": identifier, "name": json.loads(name[1]),
                     "signed": FN + "market/items/" + identifier, "raw_refund": 0})
        mc(f"market/items/{identifier}", "$" + grant.replace("custom_data={", "custom_data={sd_floor_refund:$(refund),", 1))
        mc(f"market/preview/{identifier}", "item replace entity @s contents with " + grant.split("give @s ", 1)[1].removesuffix(" 1"))

    mc("black/init", f"data modify storage {RUN} black set value {{stock:[],sold:[]}}",
       f"data modify storage {RUN} black_beta set value {literal(beta)}",
       "scoreboard players add @s zx.job 0",
       f"execute store result storage {RUN} market_query.job int 1 run scoreboard players get @s zx.job",
       f'data modify storage {RUN} market_pool set value []',
       f'data modify storage {RUN} market_pool append from storage {POOL} entries[{{job:0,group:"offhand"}}]',
       f'execute unless score @s zx.job matches 0 run function {FN}market/query_offhand with storage {RUN} market_query',
       f"function {FN}black/sample {price_record(0)}",
       f"data modify storage {RUN} market_pool set from storage {POOL} upgrades",
       f"function {FN}black/sample {price_record(1)}",
       f"data modify storage {RUN} market_pool set from storage {RUN} black_beta",
       f"function {FN}black/sample {price_record(2)}",
       f"function {FN}black/gear {price_record(3)}",
       f"function {FN}black/gear {price_record(4)}")
    # Separate equipment offers: sample the tier first, then choose stock of
    # that tier. Fallback never goes below 3 if a job lacks a higher tier.
    mc("black/gear", "execute store result score #black_roll sd.floor run random value 1..100 sweetdream:rogue",
       "scoreboard players set #black_tier sd.floor 3",
       "execute if score #black_roll sd.floor matches 71.. run scoreboard players set #black_tier sd.floor 4",
       "execute if score #black_roll sd.floor matches 99.. run scoreboard players set #black_tier sd.floor 5",
       f"function {FN}black/gear_pool",
       f"$function {FN}black/sample {{slot:$(slot),hp:$(hp),mana:$(mana),hp_code:$(hp_code),mana_code:$(mana_code)}}")
    mc("black/gear_pool", f"data modify storage {RUN} market_pool set value []",
       f"execute store result storage {RUN} market_query.tier int 1 run scoreboard players get #black_tier sd.floor",
       f"function {FN}market/query_gear with storage {RUN} market_query",
       f"execute if data storage {RUN} black.stock[3] run function {FN}market/deduplicate with storage {RUN} black.stock[3]",
       f"execute if data storage {RUN} market_pool[0] run return 1",
       "scoreboard players remove #black_tier sd.floor 1",
       f"execute if score #black_tier sd.floor matches 3.. run function {FN}black/gear_pool")
    mc("black/sample", f"execute unless data storage {RUN} market_pool[0] run return 0",
       f"execute store result score #len sd.floor run data get storage {RUN} market_pool",
       "scoreboard players remove #len sd.floor 1",
       f"execute store result storage {RUN} draw.max int 1 run scoreboard players get #len sd.floor",
       f"function {FN}reward/random with storage {RUN} draw",
       f"function {FN}black/select_index with storage {RUN} draw",
       f"$data modify storage {RUN} preview_entry merge value {{slot:$(slot),hp:$(hp),mana:$(mana),hp_code:$(hp_code),mana_code:$(mana_code)}}",
       f"data remove storage {RUN} preview_item",
       f"execute summon minecraft:item_display run function {FN}market/read_preview",
       f"data modify storage {RUN} preview_entry.preview_id set from storage {RUN} preview_item.id",
       f"data modify storage {RUN} preview_entry.preview set from storage {RUN} preview_item.components",
       f"data modify storage {RUN} black.stock append from storage {RUN} preview_entry")
    mc("black/select_index", f"$data modify storage {RUN} preview_entry set from storage {RUN} market_pool[$(index)]")
    mc("black/buy", f'$execute if data storage {RUN} black.sold[{{slot:$(slot)}}] run return 0',
       f'$execute store result score #black_paid sd.floor run function {FN}black/pay {{code:$(hp_code),hp:$(hp),mana:$(mana)}}',
       "execute unless score #black_paid sd.floor matches 1 run return 0",
       f'$function $(signed) {{refund:0}}',
       f'$data modify storage {RUN} black.sold append value {{slot:$(slot)}}',
       say("成交。", "light_purple"))
    mc("black/draw", f"execute if data storage {RUN} black.sold[{{slot:5}}] run return 0",
       f"execute store result score #black_paid sd.floor run function {FN}black/pay {price_record(5, pay=True)}",
       "execute unless score #black_paid sd.floor matches 1 run return 0",
       f"data modify storage {RUN} black.sold append value {{slot:5}}",
       f'data modify storage {RUN} draw_source set value "blackmarket"',
       f"function {FN}reward/ask")
    mc("black/stone", f"execute if data storage {RUN} black.sold[{{slot:6}}] run return 0",
       f"data remove storage {RUN} stone",
       f'data modify storage {RUN} stone.id set from entity @s SelectedItem.components."minecraft:custom_data".zx[0]',
       f"execute unless data storage {RUN} stone.id run return run " + say("主手拿着要超限的装备。", "yellow"),
       f"function {FN}black/buy_stone with storage {RUN} stone")
    mc("black/buy_stone",
       '$execute unless data storage zx:config oldef."$(id)" run return run ' + say("这件装备没有专用超限石。","yellow"),
       '$execute if items entity @s weapon.mainhand *[minecraft:custom_data~{ol:"$(id)"}] run return run ' +
       say("这件装备已经超限。", "yellow"),
       f"execute store result score #black_paid sd.floor run function {FN}black/pay {price_record(6, pay=True)}",
       "execute unless score #black_paid sd.floor matches 1 run return 0",
       "$function sweetdream:overlimit/item/$(id)",
       f"data modify storage {RUN} black.sold append value {{slot:6}}",
       say("把装备放副手，手持超限石右键。", "light_purple"))
    caps(root, mc)
    # Deal in the same typed reward as combat, with a third-through-fifth-tier
    # floor. No offhands enter this draw; they are ordinary stock.
    p = root / "reward/category.mcfunction"
    old = f"execute if score #quality_total sd.floor matches 0 run return"
    edit(p, (old, f'execute if data storage {RUN} {{draw_source:"blackmarket"}} run function {FN}reward/roll_black\n' + old))
    weights = (70, 28, 2)
    mc("reward/roll_black", "scoreboard players set #quality_total sd.floor 0",
       *(f"execute if data storage {RUN} eligible.t{i} run scoreboard players add #quality_total sd.floor {w}" for i,w in enumerate(weights,3)),
       "execute if score #quality_total sd.floor matches 0 run return 0",
       f"execute store result storage {RUN} draw.total int 1 run scoreboard players get #quality_total sd.floor",
       f"function {FN}reward/random_quality with storage {RUN} draw",
       *(line for i,w in enumerate(weights,3) for line in (
           f"execute if data storage {RUN} eligible.t{i} run scoreboard players remove #quality sd.floor {w}",
           f"execute if score #quality sd.floor matches ..0 run return run data modify storage {RUN} exact_tier set value {i}")))


def offer(name, hp_code, price, mana_code=None, hover=""):
    mana_code = hp_code + 1 if mana_code is None else mana_code
    return ('tellraw @s [{text:"    ' + name + '",color:"white"' + ("," + hover if hover else "") + '},'
            f'{{text:"    [生命 -{price[0]}%]",color:"red",click_event:{{action:"run_command",command:"/trigger sd.floor_cmd set {hp_code}"}}}},'
            f'{{text:"  [魔力 -{price[1]}%]",color:"aqua",click_event:{{action:"run_command",command:"/trigger sd.floor_cmd set {mana_code}"}}}}]')


def price_record(slot, pay=False):
    hp, mana = PRICES[slot]
    code = 100 + 2 * slot
    return f"{{code:{code},hp:{hp},mana:{mana}}}" if pay else f"{{slot:{slot},hp:{hp},mana:{mana},hp_code:{code},mana_code:{code+1}}}"


def caps(root, mc):
    for obj in ("sd.bl_hp", "sd.bl_pct", "sd.bl_mana"):
        edit(root / "load.mcfunction", ("scoreboard objectives add sd.floor ", f"scoreboard objectives add {obj} dummy\nscoreboard objectives add sd.floor "))
    mc("black/pay", "$execute if score #input sd.floor matches $(code) run return run function " +
       FN + "black/pay_hp {cost:$(hp)}",
       "$return run function " + FN + "black/pay_mana {cost:$(mana)}")
    for key, obj in (("hp", "sd.bl_hp"), ("mana", "sd.bl_pct")):
        mc(f"black/pay_{key}", f"scoreboard players add @s {obj} 0",
           f"scoreboard players operation #black_due sd.floor = @s {obj}",
           "$scoreboard players add #black_due sd.floor $(cost)",
           "execute if score #black_due sd.floor matches 61.. run " + say("这项上限最多可抵押 60%。", "yellow"),
           "execute if score #black_due sd.floor matches 61.. run return fail",
           f"scoreboard players operation @s {obj} = #black_due sd.floor",
           f"function {FN}black/update_{key}",
           "return 1")
    mc("black/update_hp",
       "attribute @s minecraft:max_health modifier remove sweetdream_floor:black_market",
       f"execute store result storage {RUN} black_rate.value double -0.01 run scoreboard players get @s sd.bl_hp",
       f"function {FN}black/set_hp with storage {RUN} black_rate")
    mc("black/set_hp", "$attribute @s minecraft:max_health modifier add sweetdream_floor:black_market $(value) add_multiplied_total")
    mc("black/update_mana", "function sweetdream:lib/uuid",
       "execute unless data storage zx:data self{ok:1b} run return 0",
       "data modify storage manacore:in arg set value {uuid:\"\",key:\"max_mana\"}",
       "data modify storage manacore:in arg.uuid set from storage zx:data self.uuid",
       "function manacore:api/stats/get",
       "execute store result score #black_new sd.floor run data get storage manacore:out r.value 100",
       "scoreboard players add @s sd.bl_mana 0",
       "scoreboard players operation #black_new sd.floor += @s sd.bl_mana",
       "scoreboard players operation #black_new sd.floor *= @s sd.bl_pct",
       "scoreboard players set #black_div sd.floor 100",
       "scoreboard players operation #black_new sd.floor /= #black_div sd.floor",
       "execute if score #black_new sd.floor = @s sd.bl_mana run return 0",
       "scoreboard players operation #black_delta sd.floor = @s sd.bl_mana",
       "scoreboard players operation #black_delta sd.floor -= #black_new sd.floor",
       "scoreboard players operation @s sd.bl_mana = #black_new sd.floor",
       f"function {FN}black/write_mana")
    mc("black/write_mana",
       "data modify storage manacore:in arg set value {uuid:\"\",value:0.0}",
       "data modify storage manacore:in arg.uuid set from storage zx:data self.uuid",
       "execute store result storage manacore:in arg.value double 0.01 run scoreboard players get #black_delta sd.floor",
       "function manacore:api/mana/max/add",
       f"function {FN}run/mana {{value:0.0}}")
    mc("black/reset",
       "execute if score @s sd.bl_hp matches 1.. run attribute @s minecraft:max_health modifier remove sweetdream_floor:black_market",
       "scoreboard players reset @s sd.bl_hp",
       "scoreboard players set @s sd.bl_pct 0",
       f"execute if score @s sd.bl_mana matches 1.. run function {FN}black/update_mana",
       "scoreboard players reset @s sd.bl_pct",
       "scoreboard players reset @s sd.bl_mana")
    edit(root / "room/event/reset.mcfunction", (f"function {FN}astrology/reset",
         f"function {FN}astrology/reset\nfunction {FN}black/reset"))
    edit(root / "room/event/second.mcfunction", (f"function {FN}room/event/mana_reconcile",
         f"function {FN}room/event/mana_reconcile\nexecute if score @s sd.bl_pct matches 1.. run function {FN}black/update_mana"))
