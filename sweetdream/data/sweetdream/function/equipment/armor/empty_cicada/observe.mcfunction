execute unless items entity @s armor.chest *[custom_data~{zx:["empty_cicada"]}] run return 0
scoreboard players add #s2_move_seq zx.meta 1
scoreboard players operation @s zx.s2_move_id = #s2_move_seq zx.meta
scoreboard players operation @s zx.s2_step_end = #now manacore.meta
scoreboard players add @s zx.s2_step_end 100
summon minecraft:marker ~ ~ ~ {Tags:["zx.s2_move_start","zx.s2_move_new"]}
scoreboard players operation @e[tag=zx.s2_move_new,distance=..1,limit=1] zx.s2_move_id = @s zx.s2_move_id
scoreboard players operation @e[tag=zx.s2_move_new,distance=..1,limit=1] zx.s2_end = @s zx.s2_step_end
tag @e[tag=zx.s2_move_new,distance=..1] remove zx.s2_move_new
