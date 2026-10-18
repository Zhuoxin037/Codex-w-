scoreboard players set #tv_old zx.meta 0
execute store result score #tv_old zx.meta run data get entity @s equipment.offhand.components."minecraft:custom_model_data".floats[1] 1
execute unless score #tv_old zx.meta matches 0 run item modify entity @s weapon.offhand sweetdream:triad_visual/idle
