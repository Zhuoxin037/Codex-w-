function sweetdream:lib/entity_id
scoreboard players set @s zx.lr_sum 0
scoreboard players set @s zx.lr_live 0
scoreboard players set @s zx.lr_hp 0
scoreboard players set @s zx.lr_ab 0
execute store result score @s zx.lr_hp run data get entity @s Health 1000
execute if data entity @s AbsorptionAmount store result score @s zx.lr_ab run data get entity @s AbsorptionAmount 1000
tag @s add zx.lr_watch
