$data modify entity @s transformation set from storage zx:fbvis frames[$(i)]
execute store result entity @s item.components."minecraft:custom_model_data".floats[0] float 1 run scoreboard players get @s zx.fb_fx_t
