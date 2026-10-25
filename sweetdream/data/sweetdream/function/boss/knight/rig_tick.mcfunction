$execute unless entity @e[tag=sd.kn.body,scores={sdk.id=$(id)},distance=0..,limit=1] run return run function sweetdream:boss/knight/death/start
tag @s add sd.kn.current_rig
tag @s remove sd.kn.frozen
$execute as @e[tag=sd.kn.body,scores={sdk.id=$(id)},distance=0..,limit=1] at @s run function sweetdream:boss/knight/body_tick
tag @s remove sd.kn.current_rig
