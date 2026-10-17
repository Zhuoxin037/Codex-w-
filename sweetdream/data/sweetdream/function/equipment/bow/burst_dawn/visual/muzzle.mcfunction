summon minecraft:item_display ~ ~ ~ {Tags:["zx.bv_display","zx.bv_muzzle","zx.bv_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:burst_dawn_muzzle","minecraft:custom_model_data":{floats:[0.0f]},"minecraft:custom_data":{zx_bv:{}}}},item_display:"fixed",billboard:"fixed",interpolation_duration:0,teleport_duration:1,view_range:2.0f,shadow_radius:0.0f,transformation:{translation:[0f,0f,0f],scale:[1f,1f,1f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}
execute as @e[tag=zx.bv_new,distance=..1,limit=1] run tp @s ~ ~ ~ ~ ~
scoreboard players set @e[tag=zx.bv_new,distance=..1,limit=1] zx.bv_age 1
tag @e[tag=zx.bv_new,distance=..1] remove zx.bv_new
