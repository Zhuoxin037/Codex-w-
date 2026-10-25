execute if entity @s[tag=sd.hk.dead] run return 0
tag @s add sd.hk.dead
tag @s remove sd.hk.frozen
scoreboard players set @s sdh.death 0
execute store result storage sweetdream:husk args.id int 1 run scoreboard players get @s aj.id
function sweetdream:boss/husk/bar/remove with storage sweetdream:husk args
function sweetdream_boss:husk/animations/death/play_exclusive
