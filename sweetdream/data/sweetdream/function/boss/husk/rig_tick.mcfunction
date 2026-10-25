$execute unless entity @e[tag=sd.hk.body,scores={sdh.id=$(id)},distance=0..,limit=1] run return run function sweetdream:boss/husk/death/start
tag @s add sd.hk.current_rig
tag @s remove sd.hk.frozen
$execute as @e[tag=sd.hk.body,scores={sdh.id=$(id)},distance=0..,limit=1] at @s run function sweetdream:boss/husk/body_tick
tag @s remove sd.hk.current_rig
