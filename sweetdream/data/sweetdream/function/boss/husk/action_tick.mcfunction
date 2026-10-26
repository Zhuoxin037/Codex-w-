scoreboard players add @s sdh.age 1
execute if score @s sdh.state matches 10 run return run function sweetdream:boss/husk/action/punch_right
execute if score @s sdh.state matches 11 run return run function sweetdream:boss/husk/action/punch_combo
execute if score @s sdh.state matches 12 run return run function sweetdream:boss/husk/action/elbow_right
execute if score @s sdh.state matches 13 run return run function sweetdream:boss/husk/action/knee_right
execute if score @s sdh.state matches 14 run return run function sweetdream:boss/husk/action/shoulder_bump
execute if score @s sdh.state matches 20..24 run return run function sweetdream:boss/husk/action/guard
execute if score @s sdh.state matches 30..33 run function sweetdream:boss/husk/action/counter

execute if score @s sdh.state matches 40..43 run function sweetdream:boss/husk/leap/tick
