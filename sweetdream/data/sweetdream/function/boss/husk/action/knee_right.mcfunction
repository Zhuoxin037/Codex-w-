execute if score @s sdh.age matches ..6 run function sweetdream:boss/husk/face
execute if score @s sdh.age matches 9.. unless score @s sdh.hit0 matches 1 run function sweetdream:boss/husk/hit/knee_right_0
execute if score @s sdh.age matches 25.. run scoreboard players set @s sdh.rest 21
execute if score @s sdh.age matches 25.. run function sweetdream:boss/husk/finish
