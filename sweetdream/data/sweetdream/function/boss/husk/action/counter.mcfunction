execute if score @s sdh.state matches 30 if score @s sdh.age matches 13.. run return run function sweetdream:boss/husk/counter/hold
execute if score @s sdh.state matches 31 run return run function sweetdream:boss/husk/counter/tick
execute if score @s sdh.state matches 32 run return run function sweetdream:boss/husk/counter/slam_tick
execute if score @s sdh.state matches 33 if score @s sdh.age matches 20.. run scoreboard players set @s sdh.rest 20
execute if score @s sdh.state matches 33 if score @s sdh.age matches 20.. run scoreboard players set @s sdh.pending_cd 1
execute if score @s sdh.state matches 33 if score @s sdh.age matches 20.. run function sweetdream:boss/husk/finish
