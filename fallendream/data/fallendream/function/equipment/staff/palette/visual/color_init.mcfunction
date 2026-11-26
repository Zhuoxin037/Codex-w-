# Visual only: combine primary/secondary colours; do not touch damage or ownership.
scoreboard players set #orb_c1 zx.pv_f 0
scoreboard players set #orb_c2 zx.pv_f 0
execute store result score #orb_c1 zx.pv_f run data get entity @s data.zx.pal.c 1
execute store result score #orb_c2 zx.pv_f run data get entity @s data.zx.pal.c2 1
execute unless score #orb_c1 zx.pv_f matches 0..3 run scoreboard players set #orb_c1 zx.pv_f 0
execute unless score #orb_c2 zx.pv_f matches 0..3 run scoreboard players set #orb_c2 zx.pv_f 0
scoreboard players operation #orb_c2 zx.pv_f *= #4 zx.pv_f
scoreboard players operation #orb_c1 zx.pv_f += #orb_c2 zx.pv_f
data modify entity @s item.components."minecraft:item_model" set value "palette:color"
data modify entity @s item.components."minecraft:custom_model_data" set value {floats:[0.0f,0.0f]}
execute store result entity @s item.components."minecraft:custom_model_data".floats[0] float 1 run scoreboard players get #orb_c1 zx.pv_f
data modify entity @s billboard set value "fixed"
data modify entity @s item_display set value "none"
data modify entity @s transformation.scale set value [0.70f,0.70f,0.70f]
scoreboard players set @s zx.pv_spin 0
data modify entity @s transformation.left_rotation set value [0.0f,0.0f,0.0f,1.0f]
