scoreboard players set #valid bs.ok 0
execute unless data entity @s Health run return 0
execute if entity @s[nbt={Health:0.0f}] run return 0
execute if entity @s[tag=sd.bs.source] run return 0
execute if entity @s[type=minecraft:player,gamemode=creative] run return 0
execute if entity @s[type=minecraft:player,gamemode=spectator] run return 0
scoreboard players set #valid bs.ok 1
