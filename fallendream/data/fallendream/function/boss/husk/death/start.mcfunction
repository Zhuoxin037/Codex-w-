execute if entity @s[tag=sd.hk.dead] run return 0
tag @s add sd.hk.dead
tag @s remove sd.hk.frozen
scoreboard players set @s sdh.death 0
execute store result storage fallendream:husk args.id int 1 run scoreboard players get @s aj.id
function fallendream:boss/husk/bar/remove with storage fallendream:husk args
function fallendream_boss:husk/animations/death/play_exclusive
