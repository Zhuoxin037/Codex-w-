# Called by the exported AJ root BEFORE its animation frame is applied.
execute unless entity @s[tag=sd.fb.rig] run return 0
execute unless entity @s[tag=sd.fb.light_v2] run function fallendream:boss/fireaxe/visual/light
execute store result storage fallendream:fireaxe args.id int 1 run scoreboard players get @s aj.id
function fallendream:boss/fireaxe/rig_tick with storage fallendream:fireaxe args
