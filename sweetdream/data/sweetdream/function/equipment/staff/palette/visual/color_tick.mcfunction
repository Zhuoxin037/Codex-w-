execute unless data entity @s item.components."minecraft:custom_model_data".floats[1] run function sweetdream:equipment/staff/palette/visual/color_init
execute unless data entity @s {transformation:{scale:[0.70f,0.70f,0.70f]}} run data modify entity @s transformation.scale set value [0.70f,0.70f,0.70f]
scoreboard players add @s zx.pv_spin 1
execute if score @s zx.pv_spin matches 16.. run scoreboard players set @s zx.pv_spin 0
scoreboard players operation #liquid_frame zx.pv_f = @s zx.pv_spin
scoreboard players set #2 zx.pv_f 2
scoreboard players operation #liquid_frame zx.pv_f /= #2 zx.pv_f
execute store result entity @s item.components."minecraft:custom_model_data".floats[1] float 1 run scoreboard players get #liquid_frame zx.pv_f
execute at @s if score @s zx.pv_spin matches 0 run particle minecraft:end_rod ~ ~ ~ 0.18 0.18 0.18 0.0 2 normal
