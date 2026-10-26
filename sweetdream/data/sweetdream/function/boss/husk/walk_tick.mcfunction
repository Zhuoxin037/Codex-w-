scoreboard players add @s sdh.age 1
execute if score @s sdh.state matches 1 if score @s sdh.age matches 6.. run function sweetdream:boss/husk/walk_loop
execute if score @s sdh.state matches 1..2 run function sweetdream:boss/husk/walk_move
execute if score @s sdh.state matches 3 if score @s sdh.age matches 6.. run function sweetdream:boss/husk/finish
