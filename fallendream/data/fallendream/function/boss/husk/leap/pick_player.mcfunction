execute if score #found sdh.tmp matches 1 run return 0
function fallendream:boss/husk/player/alive
execute unless score #alive sdh.tmp matches 1 run return 0
tag @s add sd.hk.leap_player
scoreboard players set #found sdh.tmp 1
