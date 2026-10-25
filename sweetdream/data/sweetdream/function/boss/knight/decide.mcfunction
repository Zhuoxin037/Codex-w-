execute unless entity @e[tag=sd.kn.target,distance=0..,limit=1] run return run function sweetdream:boss/knight/idle
execute if score @s sdk.rest matches 1.. run return run function sweetdream:boss/knight/idle
function sweetdream:boss/knight/face
execute if score @s sdk.scd matches 0 if entity @e[tag=sd.kn.target,distance=4..30,limit=1] unless score @s sdk.lastmove matches 4 run return run function sweetdream:boss/knight/start/shadow
execute if score @s sdk.phase matches 2 if score @s sdk.combocd matches 0 if entity @e[tag=sd.kn.target,distance=..2.05] run return run function sweetdream:boss/knight/start/combo
execute if entity @e[tag=sd.kn.target,distance=..1.85] run return run function sweetdream:boss/knight/melee_choose
execute if score @s sdk.wavecd matches 0 if entity @e[tag=sd.kn.target,distance=8..30] unless score @s sdk.lastmove matches 3 run return run function sweetdream:boss/knight/start/wave
execute if score @s sdk.dashcd matches 0 if entity @e[tag=sd.kn.target,distance=10..30] unless score @s sdk.lastmove matches 2 run return run function sweetdream:boss/knight/start/windup
execute if score @s sdk.wavecd matches 0 if entity @e[tag=sd.kn.target,distance=8..30] run return run function sweetdream:boss/knight/start/wave
execute at @s run function sweetdream:boss/knight/walk
