execute unless data entity @s Health run return 0
execute if entity @s[nbt={Health:0.0f}] run return 0
execute if entity @s[type=minecraft:player,gamemode=creative] run return 0
execute if entity @s[type=minecraft:player,gamemode=spectator] run return 0
execute if score @s sdk.id = #aggro sdk.id run return 0
tag @s add sd.kn.target
