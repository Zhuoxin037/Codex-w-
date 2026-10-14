execute if score @s zx.av_t matches 0..10 run function sweetdream:equipment/axe/anchor/visual/floor_pose
scoreboard players operation #av_world zx.meta = @s zx.av_t
scoreboard players add #av_world zx.meta 100
execute store result entity @s item.components."minecraft:custom_model_data".floats[0] float 1 run scoreboard players get #av_world zx.meta
execute if score @s zx.av_t matches 11.. run function sweetdream:equipment/axe/anchor/visual/return_flight with entity @s item.components."minecraft:custom_data".zx_an
scoreboard players add @s zx.av_t 1
execute if score @s zx.av_t matches 22.. run kill @s
