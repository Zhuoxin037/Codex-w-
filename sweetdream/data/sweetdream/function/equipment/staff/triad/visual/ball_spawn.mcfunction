# @s 是已有的法球；本函数只创建可见外壳，UUID 指针写回这颗球。
data remove entity @s data.tri_visual_new
execute if data entity @s data.tv_v0 run return 0
tag @e[type=minecraft:item_display,tag=zx.tv_new,distance=0..] remove zx.tv_new
summon minecraft:item_display ~ ~ ~ {Tags:["zx.tv_missile","zx.tv_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:triad_projectile_ice","minecraft:custom_model_data":{floats:[0.0f]}}},item_display:"fixed",billboard:"fixed",teleport_duration:1,interpolation_duration:0,view_range:2.0f,width:3.5f,height:3.5f,shadow_radius:0.0f,transformation:{translation:[0.0f,0.0f,0.0f],left_rotation:[0.0f,0.0f,0.0f,1.0f],scale:[0.0f,0.0f,0.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}}
execute unless entity @e[type=minecraft:item_display,tag=zx.tv_new,distance=0..,limit=1] run return 0
execute if data entity @s data{tri_form:1} run data modify entity @e[type=minecraft:item_display,tag=zx.tv_new,distance=0..,limit=1] item.components."minecraft:item_model" set value "sweetdream:triad_projectile_knife"
execute if data entity @s data{tri_form:2} run data modify entity @e[type=minecraft:item_display,tag=zx.tv_new,distance=0..,limit=1] item.components."minecraft:item_model" set value "sweetdream:triad_projectile_spear"
execute store result entity @s data.tv_v0 int 1 run data get entity @e[type=minecraft:item_display,tag=zx.tv_new,distance=0..,limit=1] UUID[0]
execute store result entity @s data.tv_v1 int 1 run data get entity @e[type=minecraft:item_display,tag=zx.tv_new,distance=0..,limit=1] UUID[1]
execute store result entity @s data.tv_v2 int 1 run data get entity @e[type=minecraft:item_display,tag=zx.tv_new,distance=0..,limit=1] UUID[2]
execute store result entity @s data.tv_v3 int 1 run data get entity @e[type=minecraft:item_display,tag=zx.tv_new,distance=0..,limit=1] UUID[3]
scoreboard players set @s zx.tv_age 0
scoreboard players set @e[type=minecraft:item_display,tag=zx.tv_new,distance=0..,limit=1] zx.tv_life 3
tag @e[type=minecraft:item_display,tag=zx.tv_new,distance=0..] remove zx.tv_new
