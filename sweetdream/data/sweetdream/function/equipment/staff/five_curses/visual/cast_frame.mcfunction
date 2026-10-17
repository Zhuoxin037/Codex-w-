scoreboard players operation #fcvv_age zx.fcvv_f = #now manacore.meta
scoreboard players operation #fcvv_age zx.fcvv_f -= @s zx.fcvv_s
scoreboard players operation #fcvv_frame zx.fcvv_f = #fcvv_age zx.fcvv_f
execute if score @s zx.fcvv_m matches 1 run scoreboard players add #fcvv_frame zx.fcvv_f 100
execute if score @s zx.fcvv_m matches 2 run scoreboard players add #fcvv_frame zx.fcvv_f 200
execute if score @s zx.fcvv_m matches 1 if score #fcvv_age zx.fcvv_f matches 4 run playsound minecraft:block.bone_block.hit player @a ~ ~ ~ 0.7 0.65
execute if score @s zx.fcvv_m matches 2 if score #fcvv_age zx.fcvv_f matches 1 run playsound minecraft:entity.evoker.prepare_attack player @a ~ ~ ~ 0.45 0.75
execute if score @s zx.fcvv_m matches 2 if score #fcvv_age zx.fcvv_f matches 12 run function sweetdream:equipment/staff/five_curses/visual/impact
