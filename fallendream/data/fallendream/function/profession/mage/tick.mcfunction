execute if score @s zx.j_cr_t matches 1.. run function fallendream:profession/mage/crystal_tick
execute if score @s zx.j_pick_t matches 1.. run scoreboard players remove @s zx.j_pick_t 1
execute if score @s zx.j_pick matches 1 if score @s zx.j_pick_t matches 0 run function fallendream:profession/mage/timeout
execute if score @s zx.j_pain_n matches 1.. run function fallendream:profession/mage/pain_queue_tick
execute if score @s zx.j_bloom matches 1.. run function fallendream:profession/mage/bloom_tick
execute if score @s zx.j_reborn matches 1.. run scoreboard players remove @s zx.j_reborn 1
execute if score @s zx.j_reborn matches 0 run function fallendream:profession/mage/abs_end

execute if score @s zx.j_pick matches 1 run effect give @s minecraft:resistance 1 1 true

# 超限·鹰羽帽(2026-11-22): 法球增减跟踪(获得/消耗回蓝 + 每 10 颗开独立乘区)
function fallendream:equipment/armor/eagle_hat/orb_track
