execute unless entity @e[tag=sd.hk.target,distance=0..,limit=1] run return run function sweetdream:boss/husk/stop_walk
function sweetdream:boss/husk/face
execute if entity @e[tag=sd.hk.target,distance=..1.6,limit=1] run return run function sweetdream:boss/husk/choose_melee
execute if score @s sdh.fall matches 1.. run return 0
execute unless score @s sdh.speed matches 0..80 run scoreboard players set @s sdh.speed 0
execute if score @s sdh.speed matches ..19 at @s run function sweetdream:boss/husk/pursuit_move {step:0.21,detour:0.16,bonus:0}
execute if score @s sdh.speed matches 20..39 at @s run function sweetdream:boss/husk/pursuit_move {step:0.231,detour:0.176,bonus:1}
execute if score @s sdh.speed matches 40..59 at @s run function sweetdream:boss/husk/pursuit_move {step:0.252,detour:0.192,bonus:2}
execute if score @s sdh.speed matches 60..79 at @s run function sweetdream:boss/husk/pursuit_move {step:0.273,detour:0.208,bonus:3}
execute if score @s sdh.speed matches 80 at @s run function sweetdream:boss/husk/pursuit_move {step:0.294,detour:0.224,bonus:4}
execute if score @s sdh.moved matches 1 if score @s sdh.speed matches ..79 run scoreboard players add @s sdh.speed 1
execute if score @s sdh.moved matches 0 run scoreboard players set @s sdh.speed 0
execute if score @s sdh.moved matches 0 run scoreboard players add @s sdh.blocked 1
execute if score @s sdh.moved matches 1 run scoreboard players set @s sdh.blocked 0
execute if score @s sdh.blocked matches 12.. run function sweetdream:boss/husk/stop_walk
