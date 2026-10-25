execute if score @s sdk.protect matches 1 run function sweetdream:boss/knight/shadow/release_resistance
execute if score @s sdk.protect matches 2 store result entity @s Invulnerable byte 1 run scoreboard players get @s sdk.inv
scoreboard players set @s sdk.protect 0
