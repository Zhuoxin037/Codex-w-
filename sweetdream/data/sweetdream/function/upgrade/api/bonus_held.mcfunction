# ============================================================
# sweetdream:upgrade/api/bonus_held —— 汇总主手武器上**所有升级**给的加成
# ------------------------------------------------------------
# 【出参】zx:out r = {count:0~2, dmg:0.10, mana:-0.10, cd:-0.10} (已是小数)
# 【怎么算】up 列表最多 2 项 -> 各查一次定义表再**加算**(不是各自乘)
# 【武器怎么用】伤害 ×(1+r.dmg)、魔力 ×(1+r.mana)、冷却 ×(1+r.cd)
# ============================================================

data modify storage zx:out r set value {count:0,dmg:0.0,mana:0.0,cd:0.0}
scoreboard players set #up_dmg zx.meta 0
scoreboard players set #up_mana zx.meta 0
scoreboard players set #up_cd zx.meta 0

execute store result score #up_have zx.meta run data get entity @s SelectedItem.components."minecraft:custom_data".up
execute store result storage zx:out r.count int 1 run scoreboard players get #up_have zx.meta

execute if score #up_have zx.meta matches 1.. run data modify storage zx:work up.id set from entity @s SelectedItem.components."minecraft:custom_data".up[0]
execute if score #up_have zx.meta matches 1.. run function sweetdream:upgrade/api/bonus_one with storage zx:work up
execute if score #up_have zx.meta matches 2.. run data modify storage zx:work up.id set from entity @s SelectedItem.components."minecraft:custom_data".up[1]
execute if score #up_have zx.meta matches 2.. run function sweetdream:upgrade/api/bonus_one with storage zx:work up

execute store result storage zx:out r.dmg double 0.01 run scoreboard players get #up_dmg zx.meta
execute store result storage zx:out r.mana double 0.01 run scoreboard players get #up_mana zx.meta
execute store result storage zx:out r.cd double 0.01 run scoreboard players get #up_cd zx.meta