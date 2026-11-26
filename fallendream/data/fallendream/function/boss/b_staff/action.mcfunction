execute unless entity @e[tag=sd.bs.target,distance=0..,limit=1] if score @s bs.state matches 10..16 run return run function fallendream:boss/b_staff/cancel
scoreboard players add @s bs.age 1
execute if score @s bs.state matches 2 if score @s bs.age matches 20.. run function fallendream:boss/b_staff/finish
execute if score @s bs.state matches 3 if score @s bs.age matches 9.. run function fallendream:boss/b_staff/finish
execute if score @s bs.state matches 16 run function fallendream:boss/b_staff/action/repel_guard
execute if score @s bs.state matches 10 run function fallendream:boss/b_staff/action/cast_three
execute if score @s bs.state matches 11 run function fallendream:boss/b_staff/action/fan_volley
execute if score @s bs.state matches 12 run function fallendream:boss/b_staff/action/mark_ground
execute if score @s bs.state matches 13 run function fallendream:boss/b_staff/action/ring_wave
execute if score @s bs.state matches 14 run function fallendream:boss/b_staff/action/repel_retreat
execute if score @s bs.state matches 15 run function fallendream:boss/b_staff/action/scatter_cross
