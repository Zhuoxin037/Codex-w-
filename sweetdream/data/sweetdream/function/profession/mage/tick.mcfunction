execute if score @s zx.j_cr_t matches 1.. run function sweetdream:profession/mage/crystal_tick
execute if score @s zx.j_pick_t matches 1.. run scoreboard players remove @s zx.j_pick_t 1
execute if score @s zx.j_pick matches 1 if score @s zx.j_pick_t matches 0 run function sweetdream:profession/mage/timeout
execute if score @s zx.j_pain_n matches 1.. run function sweetdream:profession/mage/pain_queue_tick
execute if score @s zx.j_bloom matches 1.. run function sweetdream:profession/mage/bloom_tick
execute if score @s zx.j_reborn matches 1.. run scoreboard players remove @s zx.j_reborn 1
execute if score @s zx.j_reborn matches 0 run function sweetdream:profession/mage/abs_end

execute if score @s zx.j_pick matches 1 run effect give @s minecraft:resistance 1 1 true
