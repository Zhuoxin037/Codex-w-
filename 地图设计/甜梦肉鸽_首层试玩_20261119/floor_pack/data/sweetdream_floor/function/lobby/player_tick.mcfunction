execute unless entity @s[tag=sd.floor_lobby_weapons_clean,tag=!sd.floor_kit] run function sweetdream_floor:run/recycle_weapons
execute unless dimension minecraft:overworld run return run function sweetdream_floor:lobby/back
execute if entity @s[y=-64,dy=145] run return run function sweetdream_floor:lobby/back
execute if entity @s[tag=sd.floor_tutorial] run return 0
execute if block ~ ~-1 ~ minecraft:amethyst_block if entity @s[x=-58,y=90,z=53,dx=5,dy=3,dz=4] run return run function sweetdream_floor:tutorial/enter
execute unless block ~ ~-1 ~ minecraft:oxidized_cut_copper run tag @s remove sd.floor_pad
execute if block ~ ~-1 ~ minecraft:oxidized_cut_copper if entity @s[tag=!sd.floor_pad,x=-58,y=90,z=39,dx=5,dy=3,dz=4] run function sweetdream_floor:lobby/pad
