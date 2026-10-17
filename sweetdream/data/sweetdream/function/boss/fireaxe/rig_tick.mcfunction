$execute unless entity @e[tag=sd.fb.body,scores={sdbf.id=$(id)},distance=0..,limit=1] run return run function sweetdream:boss/fireaxe/missing_body
tag @s add sd.fb.current_rig
tag @s remove sd.fb.frozen
$execute as @e[tag=sd.fb.body,scores={sdbf.id=$(id)},distance=0..,limit=1] at @s run function sweetdream:boss/fireaxe/body_tick
tag @s remove sd.fb.current_rig
