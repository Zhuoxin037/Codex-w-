$execute if data storage zx:jobs attack_precision_fixed."$(uuid)" run return 0
execute if score @s zx.j_b_sum matches 1.. run return 0
scoreboard players set #j_attack_old zx.meta 0
$execute store result score #j_attack_old zx.meta run data get storage manacore:players "$(uuid)".stats.base_attack 1000.0000000001
scoreboard players operation #j_attack_frac zx.meta = #j_attack_old zx.meta
scoreboard players operation #j_attack_frac zx.meta %= #1000 zx.meta
execute unless score #j_attack_frac zx.meta matches 999 run return 0
scoreboard players add #j_attack_old zx.meta 1
$execute store result storage manacore:players "$(uuid)".stats.base_attack double .001 run scoreboard players get #j_attack_old zx.meta
$data modify storage zx:jobs attack_precision_fixed."$(uuid)" set value 1b
