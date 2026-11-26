scoreboard players add @s bs.turn 1
execute if score @s bs.turn matches 4 run return run function fallendream:boss/b_staff/start/scatter_cross
execute if score @s bs.turn matches 8.. run return run function fallendream:boss/b_staff/start/ring_wave
execute store result score @s bs.choice run random value 0..2
execute if score @s bs.choice = @s bs.last run scoreboard players add @s bs.choice 1
execute if score @s bs.choice matches 3 run scoreboard players set @s bs.choice 0
scoreboard players operation @s bs.last = @s bs.choice
execute if score @s bs.choice matches 0 run return run function fallendream:boss/b_staff/start/cast_three
execute if score @s bs.choice matches 1 run return run function fallendream:boss/b_staff/start/fan_volley
function fallendream:boss/b_staff/start/mark_ground
