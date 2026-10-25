execute if score @s sdh.age matches ..4 run function sweetdream:boss/husk/face
execute if score @s sdh.age matches 7.. unless score @s sdh.hit0 matches 1 run function sweetdream:boss/husk/hit/punch_right_0
execute if score @s sdh.age matches 20.. run scoreboard players set @s sdh.rest 17
execute if score @s sdh.age matches 20.. run function sweetdream:boss/husk/finish
