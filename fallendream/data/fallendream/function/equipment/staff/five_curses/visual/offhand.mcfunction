scoreboard players set #fcvv_old zx.fcvv_f -999
execute store result score #fcvv_old zx.fcvv_f run data get entity @s equipment.offhand.components."minecraft:custom_model_data".floats[0]
execute if score #fcvv_old zx.fcvv_f = #fcvv_frame zx.fcvv_f if items entity @s weapon.offhand *[minecraft:item_model="fallendream:five_curses"] run return 0
item modify entity @s weapon.offhand fallendream:five_curses_visual/frame
