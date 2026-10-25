execute unless entity @e[tag=sd.kn.target,distance=0..,limit=1] run return run function sweetdream:boss/knight/finish
execute if score @s sdk.age matches 71.. run return run function sweetdream:boss/knight/finish
execute if entity @e[tag=sd.kn.target,distance=..2.05] run return run function sweetdream:boss/knight/start/thrust
function sweetdream:boss/knight/face
execute at @s run function sweetdream:boss/knight/move {step:0.19}
execute if score @s sdk.age matches 9.. if score @s sdk.moved matches 1 if entity @e[tag=sd.kn.target,distance=4..,limit=1] at @s run function sweetdream:boss/knight/move {step:0.18}
execute if score @s sdk.age matches 16.. if score @s sdk.moved matches 1 if entity @e[tag=sd.kn.target,distance=4..,limit=1] at @s run function sweetdream:boss/knight/move {step:0.18}
execute if score @s sdk.moved matches 0 run scoreboard players add @s sdk.blocked 1
execute if score @s sdk.moved matches 1 run scoreboard players set @s sdk.blocked 0
execute if score @s sdk.blocked matches 2.. run function sweetdream:boss/knight/finish
