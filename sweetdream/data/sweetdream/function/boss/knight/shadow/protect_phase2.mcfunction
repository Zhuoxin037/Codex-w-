scoreboard players set @s sdk.inv 0
execute store result score @s sdk.inv run data get entity @s Invulnerable
data modify entity @s Invulnerable set value 1b
scoreboard players set @s sdk.protect 2
