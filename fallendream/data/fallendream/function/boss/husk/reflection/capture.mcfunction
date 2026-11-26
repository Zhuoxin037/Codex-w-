execute if entity @s[type=minecraft:player,gamemode=creative] run return 0
execute if entity @s[type=minecraft:player,gamemode=spectator] run return 0
execute if entity @s[type=!minecraft:player] unless data entity @s Health run return 0
execute if entity @s[type=minecraft:player] run function fallendream:boss/husk/reflection/player_uuid
execute if entity @s[type=!minecraft:player] run function fallendream:boss/husk/reflection/mob_uuid
function fallendream:boss/husk/reflection/queue with storage fallendream:husk reflect_args
