scoreboard players set #nr_lethal zx.meta 0
execute if score #jbhp zx.meta > #jbself zx.meta run return 0
scoreboard players operation #nr_possible zx.meta = #jbself zx.meta
data modify storage zx:work nr_protect_player set from entity @s
scoreboard players set #nr_res zx.meta 0
execute if data storage zx:work nr_protect_player.active_effects[{id:"minecraft:resistance"}] store result score #nr_res zx.meta run data get storage zx:work nr_protect_player.active_effects[{id:"minecraft:resistance"}].amplifier
execute if data storage zx:work nr_protect_player.active_effects[{id:"minecraft:resistance"}] run scoreboard players add #nr_res zx.meta 1
scoreboard players set #nr_factor zx.meta 5
scoreboard players operation #nr_factor zx.meta -= #nr_res zx.meta
execute if score #nr_factor zx.meta matches ..0 run scoreboard players set #nr_factor zx.meta 0
scoreboard players operation #nr_possible zx.meta *= #nr_factor zx.meta
scoreboard players set #nr_five zx.meta 5
scoreboard players operation #nr_possible zx.meta /= #nr_five zx.meta
scoreboard players set #nr_abs zx.meta 0
execute if data storage zx:work nr_protect_player.AbsorptionAmount store result score #nr_abs zx.meta run data get storage zx:work nr_protect_player.AbsorptionAmount 1000
scoreboard players operation #nr_possible zx.meta -= #nr_abs zx.meta
execute if score #nr_possible zx.meta >= #jbhp zx.meta run scoreboard players set #nr_lethal zx.meta 1
