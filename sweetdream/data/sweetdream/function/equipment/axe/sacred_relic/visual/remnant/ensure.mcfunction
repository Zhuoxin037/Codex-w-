# @s = 原战斗 marker；它乘坐零尺寸 display，关系是唯一绑定，不搜索最近的遗骸。
scoreboard players set #srm_has zx.srm_f 0
execute on vehicle if entity @s[type=minecraft:item_display,tag=zx.sr_model] run scoreboard players set #srm_has zx.srm_f 1
execute if score #srm_has zx.srm_f matches 1 run return 0
execute unless score @s zx.sr_ft > #now manacore.meta run return 0
tag @e[type=minecraft:item_display,tag=zx.sr_model_new,distance=0..] remove zx.sr_model_new
summon minecraft:item_display ~ ~ ~ {Tags:["zx.sr_model","zx.sr_model_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:sacred_remnant","minecraft:custom_model_data":{floats:[100.0f],flags:[0b,0b,0b,0b,0b]}}},item_display:"fixed",billboard:"fixed",transformation:{translation:[0.0f,0.35f,0.0f],scale:[0.7f,0.7f,0.7f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]},interpolation_duration:0,teleport_duration:0,width:1.4f,height:1.5f,view_range:1.0f,shadow_radius:0.0f}
execute if data entity @s data.zx.lh run data modify entity @e[type=minecraft:item_display,tag=zx.sr_model_new,distance=0..,limit=1] item.components."minecraft:custom_model_data".flags[0] set value 1b
execute if data entity @s data.zx.ye run data modify entity @e[type=minecraft:item_display,tag=zx.sr_model_new,distance=0..,limit=1] item.components."minecraft:custom_model_data".flags[1] set value 1b
execute if data entity @s data.zx.sx run data modify entity @e[type=minecraft:item_display,tag=zx.sr_model_new,distance=0..,limit=1] item.components."minecraft:custom_model_data".flags[2] set value 1b
execute if data entity @s data.zx.dm run data modify entity @e[type=minecraft:item_display,tag=zx.sr_model_new,distance=0..,limit=1] item.components."minecraft:custom_model_data".flags[3] set value 1b
execute if data entity @s data.zx.yh run data modify entity @e[type=minecraft:item_display,tag=zx.sr_model_new,distance=0..,limit=1] item.components."minecraft:custom_model_data".flags[4] set value 1b
scoreboard players operation @e[type=minecraft:item_display,tag=zx.sr_model_new,distance=0..,limit=1] zx.srm_b = #now manacore.meta
scoreboard players operation @e[type=minecraft:item_display,tag=zx.sr_model_new,distance=0..,limit=1] zx.srm_end = @s zx.sr_ft
scoreboard players set @e[type=minecraft:item_display,tag=zx.sr_model_new,distance=0..,limit=1] zx.srm_p -1
scoreboard players set @e[type=minecraft:item_display,tag=zx.sr_model_new,distance=0..,limit=1] zx.srm_d -1
scoreboard players set @e[type=minecraft:item_display,tag=zx.sr_model_new,distance=0..,limit=1] zx.srm_last 100
ride @s mount @e[type=minecraft:item_display,tag=zx.sr_model_new,distance=0..,limit=1]
tag @e[type=minecraft:item_display,tag=zx.sr_model_new,distance=0..] remove zx.sr_model_new
