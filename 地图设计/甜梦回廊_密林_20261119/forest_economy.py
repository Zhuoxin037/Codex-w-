"""Build the Forest economy and typed rewards against the equipment in its own save."""

import json
from pathlib import Path
import re

from floor_upgrade import edit, text, write

RUN = "sweetdream_floor:run"
POOL = "sweetdream_floor:pool"
FN = "sweetdream_floor:"
WEAPONS = {"axe", "bow", "staff", "sword"}
PRICES = [4, 7, 12, 16]
REFUNDS = [1, 1, 2, 3, 4]
WEIGHTS = {"normal": [4702, 2749, 2158, 391], "elite": [3000, 3000, 3200, 800],
           "shop": [0, 6500, 3000, 500]}


def literal(value):
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"))


def button(label, code, color="gold"):
    return {"text": f"[{label}]", "color": color,
            "click_event": {"action": "run_command", "command": f"/trigger sd.floor_cmd set {code}"}}


def say(message, color="gray"):
    return "tellraw @s " + literal({"text": message, "color": color})


def stage(world):
    pack = Path(world) / "datapacks/zz_sweetdream_floor/data/sweetdream_floor"
    base = Path(world) / "datapacks/sweetdream/data/sweetdream/function"
    func = pack / "function"

    def mc(name, *lines):
        write(func / (name + ".mcfunction"), "\n".join(lines))

    def add_item(identifier, namespace, source, category, record, refund):
        body = text(source)
        grants = [line for line in body.splitlines() if line.startswith("give @s ")]
        if len(grants) != 1:
            raise ValueError(f"Expected one give command in {source}, got {len(grants)}")
        grant = grants[0]
        label = re.search(r'item_name=(?:\{\s*"?text"?\s*:\s*)?("(?:[^"\\]|\\.)*")', grant)
        if not label or "custom_data={" not in grant:
            raise ValueError(f"Unrecognized item components in {source}")
        record.update(name=json.loads(label[1]), group=category, raw_refund=refund)
        entry = f"market/items/{identifier}"
        # Retain all equipment components. Only add the actual purchase or reward value.
        tagged = grant.replace("custom_data={", 'custom_data={sd_floor_refund:$(refund),', 1)
        mc(entry, *("$" + tagged if line == grant else line for line in body.splitlines()
                    if line and not line.startswith("#")))
        record["signed"] = FN + entry
        record["fn"] = namespace
        return record

    load = []
    entries = []
    for line in text(func / "pool/load.mcfunction").splitlines():
        if " entries append value " not in line:
            load.append(line)
            continue
        before, record = line.split(" entries append value ", 1)
        record = json.loads(record)
        category = record["category"]
        group = "weapon" if category in WEAPONS else category
        if group in ("weapon", "armor") or (category == "tool" and record["id"] != "look"):
            group = "offhand" if category == "tool" else group
            name = record["fn"]
            source = base / (name.split(":")[1] + ".mcfunction")
            add_item(record["id"], name, source, group, record,
                     5 if group == "offhand" else REFUNDS[record["tier"] - 1])
            entries.append(record)
        load.append(before + " entries append value " + literal(record))
    mc("pool/load", *load, f"function {FN}market/load")

    upgrades = []
    definitions = text(base / "upgrade/def/load.mcfunction")
    for match in re.finditer(r'updef\."(\w+_a)" set value \{([^\n]*)\}', definitions):
        identifier, definition = match.groups()
        cats = re.findall(r'\bcat\d*:"([a-z]+)"', definition)
        if not ({"armor"} | WEAPONS).intersection(cats):
            continue
        path = f"upgrade/item/{identifier}"
        upgrades.append(add_item(identifier, "sweetdream:" + path, base / (path + ".mcfunction"),
                                 "upgrade", {"id": identifier, "job": 0, "tier": 1,
                                             "categories": cats}, 2))
    if not upgrades:
        raise ValueError("No alpha upgrades found")
    mc("market/load", f"data modify storage {POOL} upgrades set value {literal(upgrades)}")

    tag_file = text(func / "reward/open.mcfunction")
    tags = set(re.findall(r'check_tag \{tag:"(\w+)"', tag_file))
    supports = []
    for job in range(5):
        for group in ("weapon", "armor"):
            tiers = sorted({e["tier"] for e in entries if e["group"] == group and e["job"] in (0, job)
                            and tags.intersection(e["tags"])})
            supports.append({"job": job, "group": group, **{f"t{tier}": 1 for tier in tiers}})
    mc("market/load", text(func / "market/load.mcfunction").strip(),
       f"data modify storage {POOL} support set value {literal(supports)}")

    # Retain the pre-update picker for a saved run with a pending label menu.
    f = func / "pool/filter.mcfunction"
    edit(f, ("scoreboard players add @s zx.job 0",
             f'$execute if data storage {RUN} draw_category run return run function {FN}pool/filter_selected {{tag:"$(tag)"}}\n'
             "scoreboard players add @s zx.job 0"))
    mc("pool/filter_selected",
       f'$data modify storage {RUN} filter.tag set value "$(tag)"',
       f"data modify storage {RUN} filter.group set from storage {RUN} draw_category",
       "scoreboard players add @s zx.job 0",
       f"execute store result storage {RUN} filter.job int 1 run scoreboard players get @s zx.job",
       f"function {FN}pool/query_selected with storage {RUN} filter",
       "execute if score @s zx.job matches 0 run return 1",
       f"data modify storage {RUN} filter.job set value 0",
       f"function {FN}pool/query_selected with storage {RUN} filter")
    exact = [f'$execute if data storage {RUN} {{exact_tier:{i}}} run data modify storage {RUN} pool append from storage {POOL} '
             f'entries[{{job:$(job),tier:{i},group:"$(group)",tags:["$(tag)"]}}]' for i in range(1, 6)]
    capped = [f'$execute unless data storage {RUN} exact_tier if score #tier sd.floor matches {i}.. run data modify storage {RUN} pool append from storage {POOL} '
              f'entries[{{job:$(job),tier:{i},group:"$(group)",tags:["$(tag)"]}}]' for i in range(1, 6)]
    mc("pool/query_selected", *(exact + capped))

    mc("reward/battle_offer",
       f'data modify storage {RUN} draw_source set value "normal"',
       f'execute if data storage {RUN} current{{kind:"elite"}} run data modify storage {RUN} draw_source set value "elite"',
       f"function {FN}reward/ask")
    mc("reward/offer", f'data modify storage {RUN} draw_source set value "capped"', f"function {FN}reward/ask")
    mc("reward/ask", f"data remove storage {RUN} exact_tier", f"data remove storage {RUN} battle_draw",
       f"data remove storage {RUN} draw_category", f"data remove storage {RUN} offers",
       f"data modify storage {RUN} choosing_category set value 1b", "scoreboard players set #phase sd.floor 3",
       f"function {FN}reward/category_menu")
    mc("reward/category_menu", say("装备抽取 · 先选类别", "aqua"),
       "tellraw @s " + literal([button("武器", 38), {"text": "  "}, button("盔甲", 39)]))
    mc("reward/category",
       f"execute unless data storage {RUN} {{choosing_category:1b}} run return 0",
       f'data modify storage {RUN} filter.group set value "weapon"',
       f'execute if score #input sd.floor matches 39 run data modify storage {RUN} filter.group set value "armor"',
       "scoreboard players add @s zx.job 0",
       f"execute store result storage {RUN} filter.job int 1 run scoreboard players get @s zx.job",
       f"function {FN}reward/read_support with storage {RUN} filter",
       f"data modify storage {RUN} draw_category set from storage {RUN} filter.group",
       *(f'execute if data storage {RUN} {{draw_source:"{kind}"}} run function {FN}reward/roll_{kind}'
         for kind in WEIGHTS),
       f'execute if data storage {RUN} {{draw_source:"capped"}} run function {FN}reward/check_cap',
       f"execute if score #quality_total sd.floor matches 0 run return run " + say("这类装备暂无可抽候选，可选另一类。"),
       f"data remove storage {RUN} choosing_category", f"function {FN}reward/open")
    mc("reward/read_support", f"data remove storage {RUN} eligible",
       f'$data modify storage {RUN} eligible set from storage {POOL} support[{{job:$(job),group:"$(group)"}}]')
    mc("reward/check_cap", "scoreboard players set #quality_total sd.floor 0",
       *(f"execute if score #tier sd.floor matches {i}.. if data storage {RUN} eligible.t{i} "
         "run scoreboard players set #quality_total sd.floor 1" for i in range(1, 6)))
    mc("reward/random_quality",
       "$execute store result score #quality sd.floor run random value 1..$(total) sweetdream:rogue")
    for kind, weights in WEIGHTS.items():
        parts = [(i, weight) for i, weight in enumerate(weights, 1) if weight]
        mc(f"reward/roll_{kind}", "scoreboard players set #quality_total sd.floor 0",
           *(f"execute if data storage {RUN} eligible.t{i} run scoreboard players add #quality_total sd.floor {w}" for i, w in parts),
           "execute if score #quality_total sd.floor matches 0 run return 0",
           f"execute store result storage {RUN} draw.total int 1 run scoreboard players get #quality_total sd.floor",
           f"function {FN}reward/random_quality with storage {RUN} draw",
           *(line for i, w in parts for line in (
               f"execute if data storage {RUN} eligible.t{i} run scoreboard players remove #quality sd.floor {w}",
               f"execute if score #quality sd.floor matches ..0 run return run data modify storage {RUN} exact_tier set value {i}")))
    edit(func / "reward/show.mcfunction", ('tellraw @s {"text":"装备抽取 · 选 1 个标签"',
         f'execute if data storage {RUN} {{choosing_category:1b}} run return run function {FN}reward/category_menu\n'
         'tellraw @s {"text":"装备抽取 · 选 1 个标签"'))
    edit(func / "reward/give_go.mcfunction", ("$function $(fn)",
         f"$execute if data storage {RUN} draw_category run data modify storage {RUN} payout set value {{signed:\"$(signed)\",refund:$(raw_refund)}}\n"
         f"execute if data storage {RUN} draw_category run function {FN}market/payout with storage {RUN} payout\n"
         f"$execute unless data storage {RUN} draw_category run function $(fn)"))
    # Existing offers opened before this update can contain an older tool candidate.
    edit(func / "reward/pick_go.mcfunction", ("execute store result score #len sd.floor run data get",
         f'execute unless data storage {RUN} draw_category run data remove storage {RUN} pool[{{category:"tool"}}]\n'
         f'execute unless data storage {RUN} pool[0] run return run function {FN}reward/empty_battle_pool\n'
         "execute store result score #len sd.floor run data get"))
    edit(func / "reward/give.mcfunction", (f"data remove storage {RUN} exact_tier",
         f"data remove storage {RUN} draw_category\ndata remove storage {RUN} exact_tier"))
    edit(func / "reward/empty_battle_pool.mcfunction", (f"data remove storage {RUN} exact_tier",
         f"data remove storage {RUN} draw_category\ndata remove storage {RUN} exact_tier"))
    edit(func / "run/route.mcfunction", ("execute if score #input sd.floor matches 30..37",
         f"execute if score #input sd.floor matches 38..39 if score #phase sd.floor matches 3 run return run function {FN}reward/category\n"
         "execute if score #input sd.floor matches 30..37"),
         ("execute if score #input sd.floor matches 20..22", f"execute if score #input sd.floor matches 70..75 run return run function {FN}market/route\n"
          "execute if score #input sd.floor matches 20..22"))
    edit(func / "run/start.mcfunction", ("scoreboard players set #lumen sd.floor 0",
         "scoreboard players set #lumen sd.floor 0\n" + "\n".join(f"data remove storage {RUN} {x}" for x in
            ("merchant", "sale", "choosing_category", "draw_category", "offers", "exact_tier"))))
    edit(func / "combat/win.mcfunction", (f'execute if data storage {RUN} current{{kind:"boss"}} run return',
         f'execute if data storage {RUN} current{{kind:"boss"}} run scoreboard players add #lumen sd.floor 2\n'
         f'execute if data storage {RUN} current{{kind:"boss"}} run return'),
         ("scoreboard players add #lumen sd.floor 2\nexecute if score #hard", "scoreboard players add #lumen sd.floor 1\nexecute if score #hard"),
         ("run scoreboard players add #lumen sd.floor 1\neffect give",
          f'run scoreboard players add #lumen sd.floor 1\nexecute if data storage {RUN} current{{kind:"elite"}} run scoreboard players add #lumen sd.floor 1\neffect give'))
    build_market(mc, func)


def build_market(mc, func):
    mc("market/payout", "$function $(signed) {refund:$(refund)}")
    mc("room/info/merchant", f"function {FN}market/show")
    mc("room/service/merchant", f"function {FN}market/show")
    mc("market/route", "execute unless dimension sweetdream:floor_1_forest run return 0",
       f"function {FN}room/read", f'execute unless data storage {RUN} inspected{{kind:"merchant"}} run return 0',
       f"function {FN}market/action with storage {RUN} inspected")
    mc("market/action",
       '$execute positioned $(x) 81 $(z) unless entity @s[distance=..8] run return run ' + say("走到行商附近再操作。"),
       f"execute unless data storage {RUN} merchant.stock run function {FN}market/init",
       f"execute if score #input sd.floor matches 73 run return run function {FN}market/draw",
       f"execute if score #input sd.floor matches 74 run return run function {FN}market/quote",
       f"execute if score #input sd.floor matches 75 run return run function {FN}market/confirm",
       *(f"execute if score #input sd.floor matches {70+i} run function {FN}market/buy with storage {RUN} merchant.stock[{i}]" for i in range(3)))
    mc("market/show", f"execute unless data storage {RUN} merchant.stock run function {FN}market/init",
       say("◇  密林 · 林地行商", "green"),
       *(f"function {FN}market/stock_line with storage {RUN} merchant.stock[{i}]" for i in range(3)),
       f"execute unless data storage {RUN} merchant{{drawn:1b}} run tellraw @s " + literal(button("装备抽取 · 5 梦屑", 73)),
       "tellraw @s " + literal(button("回收主手物品", 74, "aqua")))
    mc("market/stock_line",
       f'$execute if data storage {RUN} merchant.bought[{{code:$(code)}}] run return run tellraw @s ' + literal({"text": "$(name) · 售罄", "color": "dark_gray"}),
       '$tellraw @s [{"text":"[$(name) · $(price) 梦屑]","color":"$(color)","click_event":{"action":"run_command","command":"/trigger sd.floor_cmd set $(code)"}},{"text":"$(sale)","color":"green"}]')
    mc("market/init",
       f"data modify storage {RUN} merchant set value {{stock:[],bought:[],drawn:0b}}",
       "scoreboard players set #stock_code sd.floor 70", "scoreboard players add @s zx.job 0",
       f"execute store result storage {RUN} market_query.job int 1 run scoreboard players get @s zx.job",
       "execute store result score #stock_roll sd.floor run random value 1..100 sweetdream:rogue",
       "scoreboard players set #stock_tier sd.floor 1",
       "execute if score #stock_roll sd.floor matches 71.. run scoreboard players set #stock_tier sd.floor 2",
       f"function {FN}market/equipment",
       f"function {FN}market/mixed", f"function {FN}market/mixed")
    mc("market/mixed", "execute store result score #stock_roll sd.floor run random value 1..100 sweetdream:rogue",
       f"execute if score #stock_roll sd.floor matches ..20 run return run function {FN}market/offhand",
       f"execute if score #stock_roll sd.floor matches ..45 run return run function {FN}market/alpha",
       "execute store result score #stock_roll sd.floor run random value 1..100 sweetdream:rogue",
       "scoreboard players set #stock_tier sd.floor 1",
       "execute if score #stock_roll sd.floor matches 26.. run scoreboard players set #stock_tier sd.floor 2",
       "execute if score #stock_roll sd.floor matches 71.. run scoreboard players set #stock_tier sd.floor 3",
       "execute if score #stock_roll sd.floor matches 96.. run scoreboard players set #stock_tier sd.floor 4",
       f"function {FN}market/equipment")
    mc("market/equipment", f"data modify storage {RUN} market_pool set value []",
       f"execute store result storage {RUN} market_query.tier int 1 run scoreboard players get #stock_tier sd.floor",
       f"function {FN}market/query_gear with storage {RUN} market_query",
       *(f"execute if score #stock_tier sd.floor matches {i} run scoreboard players set #stock_price sd.floor {p}" for i, p in enumerate(PRICES, 1)),
       f"function {FN}market/sample")
    mc("market/query_gear", *(f'$data modify storage {RUN} market_pool append from storage {POOL} entries[{{job:{job},tier:$(tier),group:"{kind}"}}]'
         for kind in ("weapon", "armor") for job in (0, "$(job)")))
    # Job 0 must not receive each entry twice.
    for kind in ("weapon", "armor"):
        rest = f'$data modify storage {RUN} market_pool append from storage {POOL} entries[{{job:$(job),tier:$(tier),group:"{kind}"}}]'
        edit(func / "market/query_gear.mcfunction", (rest, rest.replace("$data ", "$execute unless score @s zx.job matches 0 run data ")))
    mc("market/offhand", f"data modify storage {RUN} market_pool set value []",
       f'data modify storage {RUN} market_pool append from storage {POOL} entries[{{job:0,group:"offhand"}}]',
       f"execute unless score @s zx.job matches 0 run function {FN}market/query_offhand with storage {RUN} market_query",
       "scoreboard players set #stock_price sd.floor 15", f"function {FN}market/sample")
    mc("market/query_offhand", f'$data modify storage {RUN} market_pool append from storage {POOL} entries[{{job:$(job),group:"offhand"}}]')
    mc("market/alpha", f"data modify storage {RUN} market_pool set from storage {POOL} upgrades",
       "scoreboard players set #stock_price sd.floor 10", f"function {FN}market/sample")
    mc("market/sample", f"data modify storage {RUN} market_all set from storage {RUN} market_pool",
       *(f"execute if data storage {RUN} merchant.stock[{i}] run function {FN}market/deduplicate with storage {RUN} merchant.stock[{i}]" for i in range(2)),
       f"execute unless data storage {RUN} market_pool[0] run data modify storage {RUN} market_pool set from storage {RUN} market_all",
       f"execute unless data storage {RUN} market_pool[0] run return 0",
       f"execute store result score #len sd.floor run data get storage {RUN} market_pool",
       "scoreboard players remove #len sd.floor 1",
       f"execute store result storage {RUN} draw.max int 1 run scoreboard players get #len sd.floor",
       f"function {FN}reward/random with storage {RUN} draw",
       f"function {FN}market/lock_stock with storage {RUN} draw")
    mc("market/deduplicate", f'$data remove storage {RUN} market_pool[{{id:"$(id)"}}]')
    mc("market/lock_stock",
       f"$data modify storage {RUN} stock_item set from storage {RUN} market_pool[$(index)]",
       f"data modify storage {RUN} stock_item.sale set value \"\"",
       f'data modify storage {RUN} stock_item.color set value "gold"',
       "execute store result score #sale_roll sd.floor run random value 1..10000 sweetdream:rogue",
       "scoreboard players set #math sd.floor 8",
       "execute if score #sale_roll sd.floor matches ..888 run scoreboard players operation #stock_price sd.floor *= #math sd.floor",
       "scoreboard players set #math sd.floor 10",
       "execute if score #sale_roll sd.floor matches ..888 run scoreboard players operation #stock_price sd.floor /= #math sd.floor",
       f'execute if score #sale_roll sd.floor matches ..888 run data modify storage {RUN} stock_item.sale set value "  八折"',
       f'execute if score #sale_roll sd.floor matches ..888 run data modify storage {RUN} stock_item.color set value "yellow"',
       f"execute store result storage {RUN} stock_item.price int 1 run scoreboard players get #stock_price sd.floor",
       f"execute store result storage {RUN} stock_item.code int 1 run scoreboard players get #stock_code sd.floor",
       f"data modify storage {RUN} merchant.stock append from storage {RUN} stock_item",
       "scoreboard players add #stock_code sd.floor 1")
    mc("market/buy",
       f'$execute if data storage {RUN} merchant.bought[{{code:$(code)}}] run return run ' + say("这件商品已售罄。"),
       "$execute unless score #lumen sd.floor matches $(price).. run return run " + say("梦屑不足。", "yellow"),
       "$scoreboard players set #refund sd.floor $(price)", "scoreboard players set #math sd.floor 5",
       '$execute if data storage sweetdream_floor:run merchant.stock[{code:$(code),group:"offhand"}] run scoreboard players set #math sd.floor 2',
       '$execute if data storage sweetdream_floor:run merchant.stock[{code:$(code),group:"upgrade"}] run scoreboard players set #math sd.floor 2',
       "scoreboard players operation #refund sd.floor /= #math sd.floor", "scoreboard players add #refund sd.floor 1",
       f'$data modify storage {RUN} payout set value {{signed:"$(signed)"}}',
       f"execute store result storage {RUN} payout.refund int 1 run scoreboard players get #refund sd.floor",
       f"function {FN}market/payout with storage {RUN} payout",
       "$scoreboard players remove #lumen sd.floor $(price)",
       f"$data modify storage {RUN} merchant.bought append value {{code:$(code)}}",
       f"function {FN}market/show")
    mc("market/draw", f"execute if data storage {RUN} merchant{{drawn:1b}} run return run " + say("本层行商抽取已用过。"),
       "execute unless score #lumen sd.floor matches 5.. run return run " + say("梦屑不足。", "yellow"),
       "scoreboard players remove #lumen sd.floor 5", f"data modify storage {RUN} merchant.drawn set value 1b",
       f'data modify storage {RUN} draw_source set value "shop"', f"function {FN}reward/ask")
    mc("market/quote", f"data remove storage {RUN} sale",
       f'execute unless data entity @s SelectedItem.components."minecraft:custom_data".sd_floor_refund run return run '
       + say("主手没有可回收的本局战利品或商品。"),
       f"data modify storage {RUN} sale.item set from entity @s SelectedItem",
       f'execute store result storage {RUN} sale.value int 1 run data get entity @s SelectedItem.components."minecraft:custom_data".sd_floor_refund',
       f"function {FN}market/quote_line with storage {RUN} sale")
    mc("market/quote_line", "$tellraw @s " + literal(button("确认回收主手 · 得 $(value) 梦屑", 75, "aqua")))
    mc("market/confirm", f"execute unless data storage {RUN} sale.item run return 0",
       f"data modify storage {RUN} sale.check set from storage {RUN} sale.item",
       f"execute store success score #sale_changed sd.floor run data modify storage {RUN} sale.check set from entity @s SelectedItem",
       f"execute unless data entity @s SelectedItem run scoreboard players set #sale_changed sd.floor 1",
       "execute if score #sale_changed sd.floor matches 1 run return run " + say("主手物品已变动，请重新报价。"),
       f"item modify entity @s weapon.mainhand {FN}market/decrement",
       f"execute store result score #refund sd.floor run data get storage {RUN} sale.value",
       "scoreboard players operation #lumen sd.floor += #refund sd.floor", f"data remove storage {RUN} sale",
       f"function {FN}room/status")
    root = func.parent / "item_modifier/market/decrement.json"
    write(root, '{"function":"minecraft:set_count","count":-1,"add":true}')
