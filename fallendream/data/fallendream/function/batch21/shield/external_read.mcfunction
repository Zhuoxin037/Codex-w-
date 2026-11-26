$data modify storage zx:work s2_queue set from storage zx:b21 p."$(owner)".shields
scoreboard players set #s2_cur zx.meta 0
execute store result score #s2_cur zx.meta run data get entity @s AbsorptionAmount 1000
scoreboard players operation #s2_lost zx.meta = @s zx.s2_abs
scoreboard players operation #s2_lost zx.meta -= #s2_cur zx.meta
execute if score #s2_lost zx.meta matches 1.. run function fallendream:batch21/shield/consume
scoreboard players operation #s2_future zx.meta = #thp_v zx.meta
scoreboard players operation #s2_future zx.meta *= #1000 zx.meta
scoreboard players operation #s2_lost zx.meta = #s2_cur zx.meta
scoreboard players operation #s2_lost zx.meta -= #s2_future zx.meta
execute if score #s2_lost zx.meta matches 1.. run function fallendream:batch21/shield/consume
$data modify storage zx:b21 p."$(owner)".shields set from storage zx:work s2_queue
scoreboard players operation @s zx.s2_abs = #s2_future zx.meta
