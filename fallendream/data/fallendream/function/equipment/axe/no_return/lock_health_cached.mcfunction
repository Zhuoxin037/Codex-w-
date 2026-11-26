execute if entity @s[tag=zx.nr_clamp] run return 0
execute store result score #nr_cur zx.meta run data get storage zx:work nr_tick_player.Health 1000
execute if score #nr_cur zx.meta matches ..0 run return 0
scoreboard players add @s zx.nr_hp 0
execute if score @s zx.nr_hp matches ..0 run scoreboard players operation @s zx.nr_hp = #nr_cur zx.meta
execute if score #nr_cur zx.meta < @s zx.nr_hp run scoreboard players operation @s zx.nr_hp = #nr_cur zx.meta
execute if score #nr_cur zx.meta > @s zx.nr_hp run function fallendream:equipment/axe/no_return/clamp_health
