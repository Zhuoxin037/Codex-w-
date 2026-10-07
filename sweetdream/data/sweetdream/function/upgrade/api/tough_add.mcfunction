# ============================================================
# sweetdream:upgrade/api/tough_add —— 护甲韧性加/减差值(硬化石)
# ------------------------------------------------------------
# 【入参】#diff = 差值(可正可负)   【执行者】玩家
# 【只改原版属性 minecraft:armor_toughness】面板没有这一项。
# 【属性 id 本系统独有】sweetdream:upg_tough
# ============================================================

attribute @s minecraft:armor_toughness modifier remove sweetdream:upg_tough

scoreboard players operation @s zx.up_at += #diff zx.meta
execute if score @s zx.up_at matches 1.. run data modify storage zx:work x set value {v:0}
execute if score @s zx.up_at matches 1.. store result storage zx:work x.v int 1 run scoreboard players get @s zx.up_at
execute if score @s zx.up_at matches 1.. run function sweetdream:upgrade/api/tough_attr with storage zx:work x
