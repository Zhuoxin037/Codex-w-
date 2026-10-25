execute if entity @s[type=!minecraft:player] unless data entity @s Health run return 0
execute if entity @s[type=!minecraft:player,nbt={Health:0.0f}] run return 0
execute if entity @s[type=minecraft:player,gamemode=creative] run return 0
execute if entity @s[type=minecraft:player,gamemode=spectator] run return 0
execute if entity @s[type=minecraft:player] if score @s zx.hp_c matches ..0 run return 0
execute if score @s sdh.id = #aggro sdh.id run return 0
tag @s add sd.hk.target
