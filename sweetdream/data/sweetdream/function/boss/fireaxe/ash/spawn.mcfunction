summon minecraft:item_display ~ ~ ~ {Tags:["sd.fb.ash","sd.fb.ash_new"],teleport_duration:1,interpolation_duration:2,billboard:"fixed",view_range:0.6f,shadow_radius:0f,transformation:{translation:[0f,0f,0f],scale:[0.13f,0.13f,0.13f],left_rotation:[0.2f,0.3f,0.2f,0.9110434f],right_rotation:[0f,0f,0f,1f]},item:{id:"minecraft:paper",count:1,components:{"minecraft:item_model":"sweetdream_boss:blueprint/reconstruction/ash/flake"}}}
execute as @e[tag=sd.fb.ash_new,distance=..0.01,limit=1] run tp @s ~ ~ ~ ~ 0
scoreboard players set @e[tag=sd.fb.ash_new,distance=..0.01,limit=1] sdbf.death_age 0
tag @e[tag=sd.fb.ash_new,distance=0..] remove sd.fb.ash_new
