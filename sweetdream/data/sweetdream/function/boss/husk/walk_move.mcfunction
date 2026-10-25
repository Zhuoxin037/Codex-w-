execute unless entity @e[tag=sd.hk.target,distance=0..,limit=1] run return run function sweetdream:boss/husk/stop_walk
function sweetdream:boss/husk/face
execute if entity @e[tag=sd.hk.target,distance=..1.5,limit=1] run return run function sweetdream:boss/husk/stop_walk
execute if score @s sdh.fall matches 1.. run return 0
function sweetdream:boss/husk/move {step:0.14}
execute if score @s sdh.moved matches 0 rotated ~30 0 run function sweetdream:boss/husk/move {step:0.10}
execute if score @s sdh.moved matches 0 rotated ~-30 0 run function sweetdream:boss/husk/move {step:0.10}
execute if score @s sdh.moved matches 0 positioned ~ ~1 ~ run function sweetdream:boss/husk/move {step:0.10}
execute if score @s sdh.moved matches 0 run scoreboard players add @s sdh.blocked 1
execute if score @s sdh.moved matches 1 run scoreboard players set @s sdh.blocked 0
execute if score @s sdh.blocked matches 12.. run function sweetdream:boss/husk/stop_walk
