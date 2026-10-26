execute if score @s sdh.state matches 40 if score @s sdh.age matches 7.. run return run function sweetdream:boss/husk/leap/launch
execute if score @s sdh.state matches 41 run return run function sweetdream:boss/husk/leap/flight
execute if score @s sdh.state matches 42 if score @s sdh.fall matches 0 run return run function sweetdream:boss/husk/leap/land
execute if score @s sdh.state matches 43 if score @s sdh.age matches 3.. unless score @s sdh.hit0 matches 1 at @s run function sweetdream:boss/husk/hit/leap
execute if score @s sdh.state matches 43 if score @s sdh.age matches 21.. run scoreboard players set @s sdh.rest 30
execute if score @s sdh.state matches 43 if score @s sdh.age matches 21.. run function sweetdream:boss/husk/finish
