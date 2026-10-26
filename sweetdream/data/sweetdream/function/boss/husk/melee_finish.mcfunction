# Short defense follows the completed ordinary attack, rather than replacing the attack.
execute if entity @e[tag=sd.hk.target,distance=..3.0,limit=1] if score @s sdh.smallcd matches 0 run return run function sweetdream:boss/husk/start/counter
execute if score @s sdh.state matches 10 run scoreboard players set @s sdh.rest 20
execute if score @s sdh.state matches 11 run scoreboard players set @s sdh.rest 26
execute if score @s sdh.state matches 12 run scoreboard players set @s sdh.rest 22
execute if score @s sdh.state matches 13 run scoreboard players set @s sdh.rest 24
execute if score @s sdh.state matches 14 run scoreboard players set @s sdh.rest 32
function sweetdream:boss/husk/finish
