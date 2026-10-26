execute if entity @s[tag=sd.hk.hit] run return 0
execute if entity @s[type=!minecraft:player] unless data entity @s Health run return 0
execute if entity @s[type=minecraft:player] run function sweetdream:boss/husk/player/alive
execute if entity @s[type=minecraft:player] unless score #alive sdh.tmp matches 1 run return 0
tag @s add sd.hk.hit
function sweetdream:boss/husk/hit/within with storage sweetdream:husk damage
