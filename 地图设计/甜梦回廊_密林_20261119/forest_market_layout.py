"""Build item-backed tooltips and the Forest merchant's chat layout."""

from pathlib import Path
import re

from floor_upgrade import text, write
from forest_economy import FN, RUN, button, literal


def stage(world):
    func = Path(world) / "datapacks/zz_sweetdream_floor/data/sweetdream_floor/function"

    def mc(name, *lines):
        write(func / f"market/{name}.mcfunction", "\n".join(lines))

    for grant in (func / "market/items").glob("*.mcfunction"):
        item = re.search(r'^\$give @s (\S.*)$', text(grant), re.M)
        if not item:
            raise ValueError(f"Missing item grant in {grant}")
        argument = item[1].strip().removesuffix(" 1")
        argument = argument.replace("sd_floor_refund:$(refund),", "", 1)
        mc(f"preview/{grant.stem}", f"item replace entity @s contents with {argument}")

    mc("show",
       f"execute unless data storage {RUN} merchant.stock run function {FN}market/init",
       "tellraw @s " + literal([
           {"text":"\n林地行商", "color":"dark_green", "bold":True},
           {"text":"    余额 ", "color":"gray"},
           {"score":{"name":"#lumen","objective":"sd.floor"}, "color":"gold"},
           {"text":" 梦屑", "color":"gold"}]),
       'tellraw @s {"text":"  现货  ·  悬停查看详情，点击购买","color":"gray"}',
       *(f"function {FN}market/slot {{slot:{i}}}" for i in range(3)),
       'tellraw @s {"text":"  服务","color":"gray"}',
       f"execute unless data storage {RUN} merchant{{drawn:1b}} run tellraw @s " + literal([
           {"text":"    "}, button("装备抽取 · 5 梦屑",73), {"text":"    "}, button("回收主手",74,"aqua")]),
       f"execute if data storage {RUN} merchant{{drawn:1b}} run tellraw @s " + literal([
           {"text":"    装备抽取已用", "color":"dark_gray"}, {"text":"    "}, button("回收主手",74,"aqua")]))
    mc("slot",
       f'$execute unless data storage {RUN} merchant.stock[$(slot)] run return 0',
       f'$execute unless data storage {RUN} merchant.stock[$(slot)].preview run function {FN}market/ensure_preview {{slot:$(slot)}}',
       f'$execute unless data storage {RUN} merchant.stock[$(slot)].preview run return run function {FN}market/stock_plain with storage {RUN} merchant.stock[$(slot)]',
       f'$function {FN}market/stock_line with storage {RUN} merchant.stock[$(slot)]')
    mc("ensure_preview", f'$data modify storage {RUN} preview_entry set from storage {RUN} merchant.stock[$(slot)]',
       f"data remove storage {RUN} preview_item",
       f"execute summon minecraft:item_display run function {FN}market/read_preview",
       f'execute unless data storage {RUN} preview_item.id run return 0',
       f'$data modify storage {RUN} merchant.stock[$(slot)].preview_id set from storage {RUN} preview_item.id',
       f'$data modify storage {RUN} merchant.stock[$(slot)].preview set value {{}}',
       f'$execute if data storage {RUN} preview_item.components run data modify storage {RUN} merchant.stock[$(slot)].preview set from storage {RUN} preview_item.components')
    mc("read_preview", f"function {FN}market/preview_equipment with storage {RUN} preview_entry",
       f"data modify storage {RUN} preview_item set from entity @s item", "kill @s")
    mc("preview_equipment", f'$function {FN}market/preview/$(id)')

    hover = 'hover_event:{action:"show_item",id:"$(preview_id)",count:1,components:$(preview)}'
    chosen = 'click_event:{action:"run_command",command:"/trigger sd.floor_cmd set $(code)"}'
    sold = f'$execute if data storage {RUN} merchant.bought[{{code:$(code)}}] run return run tellraw @s '
    mc("stock_line",
       sold + '[{text:"    $(name)",color:"dark_gray",' + hover + '},{text:"    售罄",color:"dark_gray"}]',
       '$return run tellraw @s [{text:"    "},{text:"$(name)",color:"white",' + hover + ',' + chosen + '},'
       '{text:"    $(price) 梦屑",color:"$(color)",' + hover + ',' + chosen + '},'
       '{text:"$(sale)",color:"green"}]')
    mc("stock_plain", sold + '{text:"    $(name)    售罄",color:"dark_gray"}',
       '$tellraw @s [{text:"    $(name)",color:"white",' + chosen + '},'
       '{text:"    $(price) 梦屑",color:"$(color)",' + chosen + '},{text:"$(sale)",color:"green"}]')
