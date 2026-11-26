execute positioned ~ ~ ~-4 run function sweetdream:boss/knight/spawn_here
execute unless entity @e[tag=sd.kn.body,distance=..20] run return run function sweetdream_floor:combat/boss_retry
tag @e[tag=sd.kn.body,distance=..20,limit=1,sort=nearest] add sd.floor_enemy
tellraw @s {"text":"坠梦骑士 · 留意蓄力、闪现和斩击。","color":"light_purple"}
