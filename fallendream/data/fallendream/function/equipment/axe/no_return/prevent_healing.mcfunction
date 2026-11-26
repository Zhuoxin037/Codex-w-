# 在原版再生与食物回血更新之前预测本刻的治疗；临时上限只在该刻生效。
scoreboard players set #nr_prevent zx.meta 0
execute if data storage zx:work nr_tick_player.active_effects[{id:"minecraft:regeneration"}] run function fallendream:equipment/axe/no_return/regen_due
scoreboard players set #nr_natural zx.meta 0
execute store result score #nr_natural zx.meta run gamerule naturalRegeneration
execute if score #nr_natural zx.meta matches 1 run function fallendream:equipment/axe/no_return/food_due
execute unless score #nr_prevent zx.meta matches 1 run return 0
execute store result score #nr_max zx.meta run attribute @s minecraft:max_health get 1000
execute unless score @s zx.nr_hp < #nr_max zx.meta run return 0
function fallendream:equipment/axe/no_return/clamp_health
scoreboard players operation @s zx.nr_clamp_end = #now manacore.meta
scoreboard players add @s zx.nr_clamp_end 1
