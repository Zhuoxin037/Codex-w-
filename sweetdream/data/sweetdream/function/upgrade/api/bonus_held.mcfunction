# ============================================================
# sweetdream:upgrade/api/bonus_held —— 汇总**主手**这件装备上所有升级的加成
# ------------------------------------------------------------
# 【出参】zx:out r = {count:0~4, dmg, mana, cd, mm, mr, mh, mhp}
#   dmg/mana/cd = 乘区加算后的小数(0.10 = +10%)
#   mm=魔力上限 / mr=每秒回魔 / mh=每次攻击回魔 / mhp=每次攻击回魔百分比(1.5 = 1.5%)
# 【怎么算】up 列表最多 4 项 -> 逐条查定义表:
#   老三样累加, 分级链条按"同系取最高 tier"(见 bonus_take)。
# 【武器怎么用】伤害 ×(1+r.dmg)、魔力 ×(1+r.mana)、冷却 ×(1+r.cd);
#   攻击回魔读 r.mh / r.mhp(见 upgrade/api/on_hit)。
# ============================================================

data modify storage zx:out r set value {count:0,dmg:0.0,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0}
scoreboard players set #up_dmg zx.meta 0
scoreboard players set #up_mana zx.meta 0
scoreboard players set #up_cd zx.meta 0
scoreboard players set #up_mm zx.meta 0
scoreboard players set #up_mr zx.meta 0
scoreboard players set #up_mh zx.meta 0
scoreboard players set #up_mhp zx.meta 0
# 分级链条的桶每次重来(不然上一次的结果会残留)
data remove storage zx:work up_val

scoreboard players set #up_have zx.meta 0
execute store result score #up_have zx.meta run data get entity @s SelectedItem.components."minecraft:custom_data".up
execute store result storage zx:out r.count int 1 run scoreboard players get #up_have zx.meta

execute if score #up_have zx.meta matches 1.. run data modify storage zx:work up.id set from entity @s SelectedItem.components."minecraft:custom_data".up[0]
execute if score #up_have zx.meta matches 1.. run function sweetdream:upgrade/api/bonus_one with storage zx:work up
execute if score #up_have zx.meta matches 2.. run data modify storage zx:work up.id set from entity @s SelectedItem.components."minecraft:custom_data".up[1]
execute if score #up_have zx.meta matches 2.. run function sweetdream:upgrade/api/bonus_one with storage zx:work up
execute if score #up_have zx.meta matches 3.. run data modify storage zx:work up.id set from entity @s SelectedItem.components."minecraft:custom_data".up[2]
execute if score #up_have zx.meta matches 3.. run function sweetdream:upgrade/api/bonus_one with storage zx:work up
execute if score #up_have zx.meta matches 4.. run data modify storage zx:work up.id set from entity @s SelectedItem.components."minecraft:custom_data".up[3]
execute if score #up_have zx.meta matches 4.. run function sweetdream:upgrade/api/bonus_one with storage zx:work up

execute store result storage zx:out r.dmg double 0.01 run scoreboard players get #up_dmg zx.meta
execute store result storage zx:out r.mana double 0.01 run scoreboard players get #up_mana zx.meta
execute store result storage zx:out r.cd double 0.01 run scoreboard players get #up_cd zx.meta
execute store result storage zx:out r.mm int 1 run scoreboard players get #up_mm zx.meta
execute store result storage zx:out r.mr int 1 run scoreboard players get #up_mr zx.meta
execute store result storage zx:out r.mh int 1 run scoreboard players get #up_mh zx.meta
execute store result storage zx:out r.mhp double 0.01 run scoreboard players get #up_mhp zx.meta
