execute if score @s sdh.state matches 10.. run return run function sweetdream:boss/husk/action_tick
execute if score @s sdh.state matches 1..3 run return run function sweetdream:boss/husk/walk_tick
execute if score @s sdh.fall matches 1.. run return 0
execute if score @s sdh.rest matches 1.. run return 0
execute unless entity @e[tag=sd.hk.target,distance=0..,limit=1] run return 0
function sweetdream:boss/husk/face
execute if entity @e[tag=sd.hk.target,distance=..3.5,limit=1] if score @s sdh.defcd matches 0 run return run function sweetdream:boss/husk/start/defense
execute if entity @e[tag=sd.hk.target,distance=..1.65,limit=1] run return run function sweetdream:boss/husk/choose_melee
function sweetdream:boss/husk/start/walk
