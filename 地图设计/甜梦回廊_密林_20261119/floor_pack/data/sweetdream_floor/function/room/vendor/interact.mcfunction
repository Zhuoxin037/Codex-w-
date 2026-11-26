advancement revoke @s only sweetdream_floor:service/interact
execute unless entity @s[tag=sd.floor_run,tag=zx.rg_active] run return 0
execute unless score #phase sd.floor matches 1 run return 0
execute at @s unless entity @e[type=minecraft:interaction,tag=sd.floor_vendor_hitbox,distance=..5] run return 0
execute at @s run function sweetdream_floor:room/read
execute at @s run function sweetdream_floor:room/announce with storage sweetdream_floor:run inspected
