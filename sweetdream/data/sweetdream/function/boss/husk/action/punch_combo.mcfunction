execute if score @s sdh.age matches ..4 run function sweetdream:boss/husk/face
execute if score @s sdh.age matches 7.. unless score @s sdh.hit0 matches 1 run function sweetdream:boss/husk/hit/punch_combo_0
execute if score @s sdh.age matches 17.. unless score @s sdh.hit1 matches 1 run function sweetdream:boss/husk/hit/punch_combo_1
execute if score @s sdh.age matches 33.. run scoreboard players set @s sdh.rest 20
execute if score @s sdh.age matches 33.. run function sweetdream:boss/husk/finish
