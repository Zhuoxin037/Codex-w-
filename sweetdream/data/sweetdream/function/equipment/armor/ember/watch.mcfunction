scoreboard players set #em_f zx.meta 0
execute store result score #em_f zx.meta run data get entity @s Fire
execute if score #em_f zx.meta matches 1.. run tag @s add zx.em_burn
execute if score #em_f zx.meta matches 1.. run scoreboard players add #em_seen zx.meta 1
