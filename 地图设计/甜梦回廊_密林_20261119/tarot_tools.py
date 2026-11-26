"""A party chooses one floor tool and confirms any change before spending it."""
from tarot_floor import F,T,R,S,M,ACTIVE,PLAYERS,CARDS,SCENE_PLAYING,j


KEY="minecraft:paper[minecraft:custom_data~{ft_tool:1b}]"


def tap(text,number,color):
    return {"text":text,"color":color,"click_event":{"action":"run_command","command":f"/trigger sd.floor_cmd set {number}"}}


def tools(p):
    p.around(F+"run/route","matches 100..113",f"execute if score #input sd.floor matches 240..243 run return run function {T}tool/route")
    p.ft("tool/safe",
        f"execute unless entity @s[{ACTIVE}] run return 0",
        f"execute {SCENE_PLAYING} run return 0",
        f"execute unless data storage {S} card.key run return 0",
        "execute unless score #phase sd.floor matches 1 run return 0",
        f"execute if data storage {R} encounter run return 0",
        f"execute if data storage {R} choice_room run return 0",
        f"execute if entity @s[tag=sd.floor_mirror] run return 0",
        "return 1")
    p.ft("tool/route",
        f"execute unless function {T}tool/safe run return 0",
        f"execute if score #input sd.floor matches 240..241 run return run function {T}tool/claim",
        f"execute unless data storage {S} vote.owner run return 0",
        f"execute if score #input sd.floor matches 243 run return run function {T}tool/cancel with storage {S} vote",
        f"scoreboard players operation @s ft.vote = #offer {M}",
        f"function {T}tool/count")
    p.ft("tool/menu",
        f"execute if data storage {S} loot run return 0",
        'tellraw @s '+j([tap("[取倒像镜]",240,"#dcb981"),{"text":"  "},tap("[取空白牌]",241,"#c2aae9")]))
    p.ft("tool/claim",
        f"execute if data storage {S} loot run return run title @s actionbar {{text:\"本层的塔罗道具已取走\",color:\"gray\"}}",
        "execute unless score @s zx.rg_room matches 10 run return 0",
        f"scoreboard players operation @s ft.serial = #serial sd.floor",
        f"data modify storage {S} loot set value 1b",
        *(f"execute if score #input sd.floor matches {code} run function {T}tool/give_{key}"
          for code,key in ((240,"mirror"),(241,"blank"))))
    for index,key,label,model in ((1,"mirror","倒像镜","back"),(2,"blank","空白牌","fool")):
        p.asset(f"data/fallentarot/advancement/{key}.json",j({
            "criteria":{"use":{"trigger":"minecraft:using_item","conditions":{"item":{"items":"minecraft:paper",
                        "predicates":{"minecraft:custom_data":f"{{ft_tool:1b,ft_kind:{index}}}"}}}}},
            "rewards":{"function":T+"tool/use_"+key}}))
        p.ft("tool/give_"+key,
             f'give @s minecraft:paper[minecraft:custom_data={{ft_tool:1b,ft_kind:{index}}},'
             f'minecraft:item_model="fallentarot:{model}",minecraft:item_name={{text:"{label}",color:"light_purple",italic:false}},'
             'minecraft:consumable={consume_seconds:3600,animation:"none",sound:"minecraft:intentionally_empty",has_consume_particles:false},minecraft:max_stack_size=1]')
        p.ft("tool/use_"+key,
             f"advancement revoke @s only {T}{key}",
             f"execute unless function {T}tool/safe run return 0",
             f"execute unless score @s ft.serial = #serial sd.floor run return 0",
             f"execute if data storage {S} vote run return 0",
             f"data modify storage {S} vote set value {{kind:{index}}}",
             f"data modify storage {S} vote.owner set from entity @s UUID",
             f"function {T}tool/offer_{key}",
             f"scoreboard players add #offer {M} 1",
             f"scoreboard players set #time {M} 360",
             f"function {T}tool/render with storage {S} vote")
    p.ft("tool/offer_mirror",
        f"execute store result storage {S} vote.card int 1 run scoreboard players get #card {M}",
        f"scoreboard players set #turn_card {M} 1",
        f"scoreboard players operation #turn_card {M} -= #reverse {M}",
        f"function {T}tool/preview")
    p.ft("tool/offer_blank",
        f"execute store result score #new_card {M} run random value 1..2 fallentarot:cards",
        f"execute if score #new_card {M} >= #card {M} run scoreboard players add #new_card {M} 1",
        f"execute store result storage {S} vote.card int 1 run scoreboard players get #new_card {M}",
        f"execute store result score #turn_card {M} run random value 0..1 fallentarot:cards",
        f"function {T}tool/preview")
    p.ft("tool/preview",
        f"execute store result storage {S} vote.reverse int 1 run scoreboard players get #turn_card {M}",
        *(f'execute if data storage {S} vote{{card:{i},reverse:{rev}}} run data modify storage {S} vote merge value '
          f'{{title:"{name} · {side}",detail:"{detail}"}}'
          for i,(_,name,up,down) in CARDS.items() for rev,side,detail in ((0,"正位",up),(1,"逆位",down))))
    p.ft("tool/render",
        f'$tellraw {PLAYERS} ['+'{text:"◇  $(title)",color:"light_purple",bold:true},{text:"\\n$(detail)",color:"white"},'
        +j({"text":"\n"})+","+j(tap("[确认]",242,"green"))+","+j({"text":"  "})+","+j(tap("[取消]",243,"gray"))+"]")
    p.ft("tool/tick",
        f"execute unless score #phase sd.floor matches 1 run return run data remove storage {S} vote",
        f"scoreboard players remove #time {M} 1",
        f"execute if score #time {M} matches ..0 run data remove storage {S} vote")
    p.ft("tool/cancel",f"$execute if entity @s[nbt={{UUID:$(owner)}}] run data remove storage {S} vote")
    p.ft("tool/count",
        f"execute store result score #party {M} if entity {PLAYERS}",
        f"scoreboard players set #votes {M} 0",
        f"execute as {PLAYERS} if score @s ft.vote = #offer {M} run scoreboard players add #votes {M} 2",
        f"execute if score #votes {M} > #party {M} run function {T}tool/confirm with storage {S} vote")
    p.ft("tool/confirm",
        f"$execute as @a[{ACTIVE},nbt={{UUID:$(owner)}},distance=0..] if score @s ft.serial = #serial sd.floor run function {T}tool/spend with storage {S} vote")
    p.ft("tool/spend",
        f"$execute store result score #spent {M} run clear @s minecraft:paper[minecraft:custom_data~{{ft_tool:1b,ft_kind:$(kind)}}] 1",
        f"execute unless score #spent {M} matches 1 run return run data remove storage {S} vote",
        f"$scoreboard players set #card {M} $(card)",
        f"$scoreboard players set #reverse {M} $(reverse)",
        f"function {T}set_card",
        f"data remove storage {S} vote",
        f"execute as {PLAYERS} at @s if score @s zx.rg_room matches 0..24 run function {T}tool/refresh",
        f"execute as {PLAYERS} run function {T}info with storage {S} card",
        f"playsound minecraft:block.amethyst_block.chime master {PLAYERS} ~ ~ ~ .9 .85")
    p.ft("tool/refresh",
        f"execute store result storage {S} refresh.cell int 1 run scoreboard players get @s zx.rg_room",
        f"function {T}fool/visit with storage {S} refresh",
        "execute if entity @s[tag=rgp.open] run function fallenroute:floor/close")
    p.mc(F+"run/recycle_kit",f"clear @s {KEY}",*p.read(F+"run/recycle_kit"))
