execute if score @s sdh.state matches 20 if score @s sdh.age matches 17.. run return run function sweetdream:boss/husk/guard/hold
execute if score @s sdh.state matches 21 run return run function sweetdream:boss/husk/guard/tick
execute if score @s sdh.state matches 22 run return run function sweetdream:boss/husk/guard/blast_tick
execute if score @s sdh.state matches 23 if score @s sdh.age matches 42.. run scoreboard players set @s sdh.pending_cd 1
execute if score @s sdh.state matches 23 if score @s sdh.age matches 42.. run return run function sweetdream:boss/husk/finish
execute if score @s sdh.state matches 24 if score @s sdh.age matches 24.. run scoreboard players set @s sdh.rest 16
execute if score @s sdh.state matches 24 if score @s sdh.age matches 24.. run scoreboard players set @s sdh.pending_cd 1
execute if score @s sdh.state matches 24 if score @s sdh.age matches 24.. run function sweetdream:boss/husk/finish
