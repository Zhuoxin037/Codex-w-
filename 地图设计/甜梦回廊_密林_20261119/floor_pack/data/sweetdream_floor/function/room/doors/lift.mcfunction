tag @s remove sd.floor_gate_new
tag @s remove sd.floor_gate_ready
tag @s add sd.floor_gate_open
scoreboard players set @s sd.floor 8
data merge entity @s {start_interpolation:0,interpolation_duration:7,transformation:{translation:[0.0f,5.0f,0.0f]}}
