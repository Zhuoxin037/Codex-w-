data modify storage zx:elvis frame set value [0.0f]
execute store result storage zx:elvis frame[0] float 1 run scoreboard players get #el_frame zx.meta
execute on vehicle if entity @s[tag=zx.el_visual] run data modify entity @s item.components."minecraft:custom_model_data".floats set from storage zx:elvis frame
scoreboard players operation @s zx.el_last = #el_frame zx.meta
