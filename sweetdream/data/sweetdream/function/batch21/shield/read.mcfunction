$execute unless data storage zx:b21 p."$(owner)".shields run data modify storage zx:b21 p."$(owner)".shields set value []
$data modify storage zx:work s2_queue set from storage zx:b21 p."$(owner)".shields
scoreboard players set #s2_cur zx.meta 0
execute store result score #s2_cur zx.meta run data get entity @s AbsorptionAmount 1000
scoreboard players add @s zx.s2_abs 0
scoreboard players operation #s2_lost zx.meta = @s zx.s2_abs
scoreboard players operation #s2_lost zx.meta -= #s2_cur zx.meta
execute if score #s2_lost zx.meta matches 1.. run function sweetdream:batch21/shield/consume
data modify storage zx:work s2_keep set value []
scoreboard players set #s2_expired zx.meta 0
execute if data storage zx:work s2_queue[0] run function sweetdream:batch21/shield/scan
