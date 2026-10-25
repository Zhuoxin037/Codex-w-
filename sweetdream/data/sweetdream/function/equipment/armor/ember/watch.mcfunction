scoreboard players set #em_f zx.meta 0
execute store result score #em_f zx.meta run data get entity @s Fire
execute if score #em_f zx.meta matches 1.. run scoreboard players set @s zx.em_burn 1
execute if score #em_f zx.meta matches 1.. run scoreboard players add #em_seen zx.meta 1
