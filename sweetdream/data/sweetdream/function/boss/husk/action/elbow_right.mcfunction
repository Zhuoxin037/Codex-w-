execute if score @s sdh.age matches ..5 run function sweetdream:boss/husk/face
execute if score @s sdh.age matches 8.. unless score @s sdh.hit0 matches 1 run function sweetdream:boss/husk/hit/elbow_right_0
execute if score @s sdh.age matches 23.. run scoreboard players set @s sdh.rest 18
execute if score @s sdh.age matches 23.. run function sweetdream:boss/husk/finish
