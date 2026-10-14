# @s = 原逻辑 marker。marker 乘坐零尺寸显示实体，直接关系绑定，不寻找附近别人的灯。
scoreboard players set #el_vehicle zx.meta 0
execute on vehicle if entity @s[type=minecraft:item_display,tag=zx.el_visual] run scoreboard players set #el_vehicle zx.meta 1
execute if score #el_vehicle zx.meta matches 1 run return 0
execute unless data entity @s data.zx.el.x run data modify entity @s data.zx.el.x set value 0.0d
execute unless data entity @s data.zx.el.y run data modify entity @s data.zx.el.y set value 0.0d
execute unless data entity @s data.zx.el.z run data modify entity @s data.zx.el.z set value 0.0d
tag @e[type=minecraft:item_display,tag=zx.el_visual_new,distance=0..] remove zx.el_visual_new
summon minecraft:item_display ~ ~ ~ {Tags:["zx.el_visual","zx.el_visual_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:everlit_wisp","minecraft:custom_model_data":{floats:[400.0f]}}},item_display:"fixed",billboard:"fixed",transformation:{translation:[0.0f,0.0f,0.0f],scale:[0.72f,0.72f,0.72f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]},brightness:{block:6,sky:6},teleport_duration:2,interpolation_duration:0,width:1.4f,height:1.8f,view_range:0.75f,shadow_radius:0.0f}
ride @s mount @e[type=minecraft:item_display,tag=zx.el_visual_new,distance=0..,limit=1]
tag @e[type=minecraft:item_display,tag=zx.el_visual_new,distance=0..] remove zx.el_visual_new
scoreboard players set @s zx.el_last -1
scoreboard players set @s zx.el_dim -1
