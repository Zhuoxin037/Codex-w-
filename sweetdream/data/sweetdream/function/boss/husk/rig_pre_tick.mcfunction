execute unless entity @s[tag=sd.hk.rig] run return 0
execute if entity @s[tag=sd.hk.dead] run return run function sweetdream:boss/husk/death/tick
execute store result storage sweetdream:husk args.id int 1 run scoreboard players get @s aj.id
function sweetdream:boss/husk/rig_tick with storage sweetdream:husk args
