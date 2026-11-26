execute if score @s sdh.state matches 10.. run return run function fallendream:boss/husk/action_tick
execute if score @s sdh.fall matches 1.. run return 0
execute unless entity @e[tag=sd.hk.target,distance=0..,limit=1] run return run scoreboard players set @s sdh.speed 0
function fallendream:boss/husk/face
execute if score @s sdh.bigcd matches 0 run return run function fallendream:boss/husk/start/guard
execute if score @s sdh.rest matches 1.. run return 0
execute if score @s sdh.state matches 1..3 run return run function fallendream:boss/husk/walk_tick
execute if entity @e[tag=sd.hk.target,distance=..1.65,limit=1] run return run function fallendream:boss/husk/choose_melee
function fallendream:boss/husk/start/walk
