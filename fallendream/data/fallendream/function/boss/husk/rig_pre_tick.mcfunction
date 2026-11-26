execute unless entity @s[tag=sd.hk.rig] run return 0
execute if entity @s[tag=sd.hk.dead] run return run function fallendream:boss/husk/death/tick
execute store result storage fallendream:husk args.id int 1 run scoreboard players get @s aj.id
function fallendream:boss/husk/rig_tick with storage fallendream:husk args
