execute unless entity @s[tag=sd.kn.rig] run return 0
execute if entity @s[tag=sd.kn.dead] run return run function sweetdream:boss/knight/death/tick
execute store result storage sweetdream:knight args.id int 1 run scoreboard players get @s aj.id
function sweetdream:boss/knight/rig_tick with storage sweetdream:knight args
