execute if score @s zx.bf_oend matches 1.. run attribute @s minecraft:armor modifier remove sweetdream:bf_a_up
execute if score @s zx.bf_oend matches 1.. run attribute @s minecraft:armor_toughness modifier remove sweetdream:bf_t_up
$attribute @s minecraft:armor modifier add sweetdream:bf_a_up $(armor) add_value
$attribute @s minecraft:armor_toughness modifier add sweetdream:bf_t_up $(toughness) add_value
scoreboard players operation @s zx.bf_oend = #now manacore.meta
scoreboard players add @s zx.bf_oend 100
execute if score #bf_set zx.meta matches 1 run function sweetdream:equipment/armor/borrow_fire/set_bonus
