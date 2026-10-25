execute if score @s sdh.age matches ..7 run function sweetdream:boss/husk/face
execute if score @s sdh.age matches 5..9 if score @s sdh.fall matches 0 run function sweetdream:boss/husk/move {step:0.18}
execute if score @s sdh.age matches 10.. unless score @s sdh.hit0 matches 1 run function sweetdream:boss/husk/hit/shoulder_bump_0
execute if score @s sdh.age matches 26.. run scoreboard players set @s sdh.rest 28
execute if score @s sdh.age matches 26.. run function sweetdream:boss/husk/finish
