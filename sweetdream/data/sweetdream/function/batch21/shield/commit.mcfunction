$data modify storage zx:b21 p."$(owner)".shields set from storage zx:work s2_keep
scoreboard players operation @s zx.s2_abs_next = #now manacore.meta
scoreboard players add @s zx.s2_abs_next 1200
data modify storage zx:work s2_queue set from storage zx:work s2_keep
execute if data storage zx:work s2_queue[0] run function sweetdream:batch21/shield/next
tag @s remove zx.s2_shield
execute if data storage zx:work s2_keep[0] run tag @s add zx.s2_shield
execute if score #s2_target zx.meta matches ..0 run scoreboard players set #s2_target zx.meta 0
execute if score #s2_target zx.meta matches 1024001.. run scoreboard players set #s2_target zx.meta 1024000
scoreboard players operation @s zx.s2_abs = #s2_target zx.meta
execute if score #s2_target zx.meta matches 0 run return run function sweetdream:lib/thp/clear
function sweetdream:batch21/shield/set
