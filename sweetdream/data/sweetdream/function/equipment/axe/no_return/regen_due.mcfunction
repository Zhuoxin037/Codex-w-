execute store result score #nr_amp zx.meta run data get storage zx:work nr_tick_player.active_effects[{id:"minecraft:regeneration"}].amplifier
execute store result score #nr_duration zx.meta run data get storage zx:work nr_tick_player.active_effects[{id:"minecraft:regeneration"}].duration
scoreboard players set #nr_period zx.meta 50
execute if score #nr_amp zx.meta matches 1 run scoreboard players set #nr_period zx.meta 25
execute if score #nr_amp zx.meta matches 2 run scoreboard players set #nr_period zx.meta 12
execute if score #nr_amp zx.meta matches 3 run scoreboard players set #nr_period zx.meta 6
execute if score #nr_amp zx.meta matches 4 run scoreboard players set #nr_period zx.meta 3
execute if score #nr_amp zx.meta matches 5.. run scoreboard players set #nr_period zx.meta 1
execute if score #nr_duration zx.meta matches ..0 run scoreboard players set #nr_prevent zx.meta 1
scoreboard players operation #nr_duration zx.meta %= #nr_period zx.meta
execute if score #nr_duration zx.meta matches 0 run scoreboard players set #nr_prevent zx.meta 1
