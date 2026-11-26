"""Physical shop displays and combat health bars for the Forest map."""

from forest_economy import FN, RUN, literal


SHOP = FN + "shop/"
HP = FN + "mob_hp/"
ST = "sweetdream_floor:exhibits"
TICK = "#clock sd.exhibit"


def stage(read, mc, replace, before, append):
    append("load", "scoreboard objectives add sd.exhibit dummy")
    anchor = f"function {FN}lobby/rejoin/tick"
    dims = ("sweetdream:floor_1_forest", "sweetdream:floor_2_trial")
    hook = "\n".join(f"execute in {dim} if entity @a[tag=sd.floor_run,distance=0..] run function {FN}exhibits/tick" for dim in dims)
    before("tick", anchor, hook)
    mc("exhibits/tick", f"execute if score #phase sd.floor matches 1 run function {SHOP}tick",
       f"execute if score #phase sd.floor matches 2 run function {HP}tick",
       f"execute as @e[type=text_display,tag=sd.mob_healthbar,distance=0..] run function {HP}prune")
    for key, dim in zip(("forest", "trial"), dims):
        for tag in ("sd.shop_display", "sd.mob_healthbar"):
            append(f"combat/clean_{key}", f"execute in {dim} run kill @e[tag={tag},distance=0..]")
    health(mc)
    stores(read, mc, replace, append)


def health(mc):
    enemies = "@e[tag=sd.floor_enemy,distance=0..,nbt=!{Health:0.0f}]"
    mc("mob_hp/tick", f"scoreboard players add {TICK} 1",
       f"execute unless score {TICK} matches 4.. run return 0",
       f"scoreboard players set {TICK} 0",
       f"execute as {enemies} at @s run function {HP}update")
    mc("mob_hp/update", "execute unless data entity @s Health run return 0",
       "execute store result score #hp sd.exhibit run data get entity @s Health 100",
       "execute unless score #hp sd.exhibit matches 1.. run return 0",
       "execute store result score #max sd.exhibit run attribute @s minecraft:max_health get 100",
       "execute unless score #max sd.exhibit matches 1.. run return 0",
       "scoreboard players set #bar_found sd.exhibit 0",
       "execute on passengers if entity @s[tag=sd.mob_healthbar] run scoreboard players set #bar_found sd.exhibit 1",
       f"execute if score #bar_found sd.exhibit matches 0 run function {HP}create",
       "execute if score #hp sd.exhibit = @s sd.exhibit if score #bar_found sd.exhibit matches 1 run return 0",
       "scoreboard players operation @s sd.exhibit = #hp sd.exhibit",
       "scoreboard players set #bar_segments sd.exhibit 10",
       "scoreboard players operation #bar_segments sd.exhibit *= #hp sd.exhibit",
       "scoreboard players operation #bar_segments sd.exhibit /= #max sd.exhibit",
       f"execute on passengers if entity @s[tag=sd.mob_healthbar] run function {HP}fill")
    mc("mob_hp/create", "tag @s add sd.mob_bar_mount",
       f"execute summon minecraft:text_display run function {HP}bind", "tag @s remove sd.mob_bar_mount")
    mc("mob_hp/bind", 'data merge entity @s {Tags:["sd.mob_healthbar"],billboard:"center",view_range:.4f,'
       'background:0,shadow:1b,transformation:{translation:[0f,.32f,0f],scale:[.63f,.63f,.63f],'
       'left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}',
       "ride @s mount @e[tag=sd.mob_bar_mount,distance=..1,limit=1]")
    mc("mob_hp/prune", "execute store success score #bar_live sd.exhibit on vehicle if entity @s[tag=sd.floor_enemy,nbt=!{Health:0.0f}]",
       "execute unless score #bar_live sd.exhibit matches 1 run kill @s")
    mc("mob_hp/fill", *(f"execute if score #bar_segments sd.exhibit matches {count} run data modify entity @s text set value " +
                         literal([{"text":"▰"*count,"color":"#ef7860"},{"text":"▰"*(10-count),"color":"#683d3a"}])
                         for count in range(11)))


def stores(read, mc, replace, append):
    for prefix, data, kind, columns, block in (
        ("market", "merchant", "merchant", (-4,-2,2), "chiseled_stone_bricks"),
        ("black", "black", "blackmarket", (-6,-4,-2,2,4), "polished_blackstone"),
    ):
        show = read(f"{prefix}/show")
        services = [line for line in show.splitlines() if "[装备抽取" in line or "已用" in line or "black.sold[{slot:6}]" in line]
        if prefix == "black":
            services = [line for line in show.splitlines() if "black.sold[{slot:5}]" in line or "black.sold[{slot:6}]" in line]
        mc(f"{prefix}/show",
           f"execute unless data storage {RUN} {data}.stock run function {FN}{prefix}/init",
           f"function {SHOP}{prefix} with storage {RUN} inspected", *services)
        mc(f"shop/{prefix}", f'$execute positioned $(x) 81 $(z) run function {SHOP}{prefix}_at')
        mc(f"shop/{prefix}_at",
           "kill @e[tag=sd.shop_display,distance=..10]",
           *(f"execute positioned ~{x} ~ ~5 run function {SHOP}{prefix}_{i}" for i,x in enumerate(columns)))
        for i, x in enumerate(columns):
            index = f"{{code:{70+i}}}" if prefix == "market" else f"{{slot:{i}}}"
            sold = "bought" if prefix == "market" else "sold"
            setup = (f"execute unless data storage {RUN} {data}.stock[{i}].preview_id run function {FN}market/ensure_preview {{slot:{i}}}",) if prefix == "market" else ()
            mc(f"shop/{prefix}_{i}", f"setblock ~ ~ ~ minecraft:{block}",
               f'execute if data storage {RUN} {data}.{sold}[{index}] run return run function {SHOP}sold',
               *setup,
               f"execute if data storage {RUN} {data}.stock[{i}].preview_id run function {SHOP}item with storage {RUN} {data}.stock[{i}]",
               f"execute if data storage {RUN} {data}.stock[{i}].preview_id run function {SHOP}{prefix}_tag with storage {RUN} {data}.stock[{i}]")
        refresh = f"function {SHOP}{prefix} with storage {RUN} inspected"
        if prefix == "market":
            replace("market/buy", f"function {FN}market/show", refresh)
        else:
            append("black/buy", refresh)

    billboard = 'billboard:"center",background:671088640,shadow:1b,view_range:.4f,transformation:{translation:[0f,0f,0f],scale:[.72f,.72f,.72f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}'
    mc("shop/sold", 'summon minecraft:text_display ~.5 ~1.5 ~.5 {Tags:["sd.shop_display"],text:{text:"售罄",color:"gray"},' + billboard + '}')
    asset = 'transformation:{translation:[0f,0f,0f],scale:[.82f,.82f,.82f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}'
    mc("shop/item", '$summon minecraft:item_display ~.5 ~1.42 ~.5 {Tags:["sd.shop_display"],item_display:"fixed",'
       'billboard:"vertical",brightness:{block:14,sky:12},width:1.5f,height:1.5f,item:{id:"$(preview_id)",count:1,components:$(preview)},' + asset + '}')
    mc("shop/market_tag",
       '$summon minecraft:text_display ~.5 ~2.04 ~.5 {Tags:["sd.shop_display"],text:[{text:"$(name)",color:"white"},{text:"\\n$(price) 梦屑",color:"gold"},{text:"$(sale)",color:"green"}],' + billboard + '}',
       f'$function {SHOP}target {{code:$(code)}}')
    mc("shop/black_tag",
       '$summon minecraft:text_display ~.5 ~2.04 ~.5 {Tags:["sd.shop_display"],text:[{text:"$(name)",color:"light_purple"},{text:"\\n右键 血−$(hp)%",color:"red"},{text:"  潜行右键 魔−$(mana)%",color:"aqua"}],' + billboard + '}',
       f'$function {SHOP}target {{code:$(hp_code)}}')
    mc("shop/target", f'$execute positioned ~.5 ~1 ~.5 summon minecraft:interaction run function {SHOP}click_body {{code:$(code)}}')
    mc("shop/click_body", 'data merge entity @s {Tags:["sd.shop_display","sd.shop_click"],width:.95f,height:1.15f,response:1b}',
       '$scoreboard players set @s sd.exhibit $(code)')
    mc("shop/tick", f"execute as @e[type=minecraft:interaction,tag=sd.shop_click,distance=0..] at @s if data entity @s interaction.player run function {SHOP}click")
    mc("shop/click", f"data modify storage {ST} click.player set from entity @s interaction.player",
       "data remove entity @s interaction", "scoreboard players operation #shop_code sd.exhibit = @s sd.exhibit",
       f"function {SHOP}player with storage {ST} click")
    mc("shop/player", f'$execute as @a[tag=sd.floor_run,tag=zx.rg_active,distance=..6,nbt={{UUID:$(player)}}] at @s run function {SHOP}buy')
    mc("shop/buy", "scoreboard players operation #input sd.floor = #shop_code sd.exhibit",
       f"execute if score #input sd.floor matches 100..109 if predicate fallendream:is_sneaking run scoreboard players add #input sd.floor 1",
       f"execute if score #input sd.floor matches 70..72 run return run function {FN}market/route",
       f"execute if score #input sd.floor matches 100..109 run return run function {FN}black/route")
