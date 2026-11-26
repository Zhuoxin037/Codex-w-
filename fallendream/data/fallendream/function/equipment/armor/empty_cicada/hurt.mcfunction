# ============================================================
# 2026-11-22 超限·空蝉：+12 生命 / +5 基础攻击（batch21/second 登记）；
#   余影 4→12 秒；"存在余影时不能再次召唤"取代基础版的 16 秒 CD；
#   爆裂后额外"吸引 + 12 点临时生命 5 秒 + 起终点各一个 30 秒的额外余影"。
# ============================================================
scoreboard players set #ec_ol zx.meta 0
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["empty_cicada"],ol:"empty_cicada"}] run scoreboard players set #ec_ol zx.meta 1

# ★ 超限用"余影还在不在"当闸（账本记到期刻，玩家各自独立）★
#   基础版仍是 16 秒 CD，两档互斥；额外余影（zx.s2_cicada_extra）不算。
scoreboard players add @s zx.s2_cicada_end 0
execute if score #ec_ol zx.meta matches 1 if score @s zx.s2_cicada_end > #now manacore.meta run return 0
execute unless score #ec_ol zx.meta matches 1 if score @s zx.s2_cicada_cd > #now manacore.meta run return 0
execute unless score #ec_ol zx.meta matches 1 run scoreboard players operation @s zx.s2_cicada_cd = #now manacore.meta
execute unless score #ec_ol zx.meta matches 1 run scoreboard players add @s zx.s2_cicada_cd 320

data modify storage zx:work s2_shadow set value {owner:"",u0:0,u1:0,u2:0,u3:0}
execute if score #ec_ol zx.meta matches 1 run data modify storage zx:work s2_shadow.ol set value 1b
function fallendream:lib/uuid
data modify storage zx:work s2_shadow.owner set from storage zx:data self.uuid
execute store result storage zx:work s2_shadow.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work s2_shadow.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work s2_shadow.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work s2_shadow.u3 int 1 run scoreboard players get @s manacore.u3
summon minecraft:marker ~ ~ ~ {Tags:["zx.s2_cicada","zx.s2_shadow_new"],data:{}}
data modify entity @e[tag=zx.s2_shadow_new,distance=..1,limit=1] data set from storage zx:work s2_shadow
scoreboard players operation @e[tag=zx.s2_shadow_new,distance=..1,limit=1] zx.s2_end = #now manacore.meta
scoreboard players add @e[tag=zx.s2_shadow_new,distance=..1,limit=1] zx.s2_end 80
execute if score #ec_ol zx.meta matches 1 run scoreboard players add @e[tag=zx.s2_shadow_new,distance=..1,limit=1] zx.s2_end 160
tag @e[tag=zx.s2_shadow_new,distance=..1] remove zx.s2_shadow_new

# 超限：记"本体余影"的到期刻（4 秒 + 额外 8 秒 = 12 秒 = 240 刻）
execute if score #ec_ol zx.meta matches 1 run scoreboard players operation @s zx.s2_cicada_end = #now manacore.meta
execute if score #ec_ol zx.meta matches 1 run scoreboard players add @s zx.s2_cicada_end 240
