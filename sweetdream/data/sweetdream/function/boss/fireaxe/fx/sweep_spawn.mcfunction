summon minecraft:item_display ~ ~2.05 ~ {Tags:["sd.fb.fx","sd.fb.fx_new","sd.fb.fx.sweep"],item_display:"none",view_range:8f,width:12f,height:5f,brightness:{block:15,sky:15},shadow_radius:0f,interpolation_duration:0,transformation:{translation:[0f,0f,0f],left_rotation:[0f,0f,0f,1f],scale:[3.5f,3.5f,3.5f],right_rotation:[0f,0f,0f,1f]},item:{id:"minecraft:paper",count:1,components:{"minecraft:item_model":"sweetdream_boss:blueprint/reconstruction/fx/sweep_0"}}}
execute as @e[tag=sd.fb.fx_new,distance=..3,limit=1] run tp @s ~ ~2.05 ~ ~ 0
scoreboard players set @e[tag=sd.fb.fx_new,distance=..3,limit=1] sdbf.fxage 0
tag @e[tag=sd.fb.fx_new,distance=..3] remove sd.fb.fx_new
