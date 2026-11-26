scoreboard players set @s sdh.speed 0
execute store result score @s sdh.choice run random value 0..4
execute if score @s sdh.choice matches 0 run return run function fallendream:boss/husk/start/punch_right
execute if score @s sdh.choice matches 1 run return run function fallendream:boss/husk/start/punch_combo
execute if score @s sdh.choice matches 2 run return run function fallendream:boss/husk/start/elbow_right
execute if score @s sdh.choice matches 3 run return run function fallendream:boss/husk/start/knee_right
function fallendream:boss/husk/start/shoulder_bump
