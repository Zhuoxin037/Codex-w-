# Called by the exported AJ root BEFORE its animation frame is applied.
execute unless entity @s[tag=sd.fb.rig] run return 0
execute unless entity @s[tag=sd.fb.light_v2] run function sweetdream:boss/fireaxe/visual/light
execute store result storage sweetdream:fireaxe args.id int 1 run scoreboard players get @s aj.id
function sweetdream:boss/fireaxe/rig_tick with storage sweetdream:fireaxe args
