execute unless entity @s[tag=zx.nr_active] run return 0
execute unless score @s zx.hurt_evt matches 1.. run return 0
execute store result score #nr_cur zx.meta run data get entity @s Health 1000
scoreboard players operation #nr_diff zx.meta = @s zx.nr_hp
scoreboard players operation #nr_diff zx.meta -= #nr_cur zx.meta
scoreboard players operation #nr_error zx.meta = #nr_diff zx.meta
scoreboard players operation #nr_error zx.meta -= @s zx.hurt_evt
execute if score #nr_diff zx.meta matches 0.. if score #nr_error zx.meta matches -50..50 run scoreboard players operation @s zx.nr_hp = #nr_cur zx.meta
execute unless score #nr_diff zx.meta matches 0.. run scoreboard players operation @s zx.nr_hp -= @s zx.hurt_evt
execute if score #nr_diff zx.meta matches 0.. unless score #nr_error zx.meta matches -50..50 run scoreboard players operation @s zx.nr_hp -= @s zx.hurt_evt
execute if score #nr_cur zx.meta < @s zx.nr_hp run scoreboard players operation @s zx.nr_hp = #nr_cur zx.meta
execute if score @s zx.nr_hp matches ..0 if score #nr_cur zx.meta matches 1.. run scoreboard players set @s zx.nr_hp 1
execute if score #nr_cur zx.meta > @s zx.nr_hp if score @s zx.nr_hp matches 1.. run function fallendream:equipment/axe/no_return/clamp_health
