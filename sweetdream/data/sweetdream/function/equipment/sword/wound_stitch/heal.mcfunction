# 按本次未合伤的60%恢复，保留千分之一生命精度。
scoreboard players operation #wst_heal zx.meta = #wst_wound zx.meta
scoreboard players set #wst_sixty zx.meta 60
scoreboard players set #wst_hundred zx.meta 100
scoreboard players operation #wst_heal zx.meta *= #wst_sixty zx.meta
scoreboard players operation #wst_heal zx.meta /= #wst_hundred zx.meta
execute unless score #wst_heal zx.meta matches 1.. run return 0
execute store result score #wst_health zx.meta run data get entity @s Health 1000
execute store result score #wst_cap zx.meta run attribute @s minecraft:max_health get 1000
scoreboard players operation #wst_base zx.meta = #wst_health zx.meta
execute if entity @s[tag=zx.heal_p] if score #wst_cap zx.meta > #wst_base zx.meta run scoreboard players operation #wst_base zx.meta = #wst_cap zx.meta
execute if entity @s[tag=zx.heal_on] if score #wst_cap zx.meta > #wst_base zx.meta run scoreboard players operation #wst_base zx.meta = #wst_cap zx.meta
execute if entity @s[tag=zx.heal_p] run attribute @s minecraft:max_health modifier remove sweetdream:heal_cap
execute if entity @s[tag=zx.heal_on] run attribute @s minecraft:max_health modifier remove sweetdream:heal_cap
tag @s remove zx.heal_p
tag @s remove zx.heal_on
execute store result score #wst_cap zx.meta run attribute @s minecraft:max_health get 1000
scoreboard players operation #wst_new zx.meta = #wst_base zx.meta
scoreboard players operation #wst_new zx.meta += #wst_heal zx.meta
execute if score #wst_new zx.meta > #wst_cap zx.meta run scoreboard players operation #wst_new zx.meta = #wst_cap zx.meta
scoreboard players operation #wst_diff zx.meta = #wst_new zx.meta
scoreboard players operation #wst_diff zx.meta -= #wst_cap zx.meta
data modify storage zx:work hp set value {d:0.0}
execute store result storage zx:work hp.d double 0.001 run scoreboard players get #wst_diff zx.meta
function sweetdream:lib/heal_up with storage zx:work hp
