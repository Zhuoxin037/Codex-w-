# 目标UUID独立保存在玩家记录；临时射线标记不参与后续跨刻。
$data modify storage zx:anchor players."$(uuid)".cast set from storage zx:anchor new
tag @e[type=minecraft:item_display,tag=zx.av_new,distance=0..] remove zx.av_new
$execute rotated ~ 0 positioned ^0.35 ^1.15 ^0.55 run summon minecraft:item_display ~ ~ ~ {Tags:["zx.av_anchor","zx.av_$(uuid)","zx.av_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:anchor_flight","minecraft:custom_model_data":{floats:[0.0f]},"minecraft:custom_data":{}}},item_display:"fixed",billboard:"fixed",teleport_duration:1,interpolation_duration:0,width:4.0f,height:4.0f,view_range:1.5f,shadow_radius:0.0f}
data modify entity @e[type=minecraft:item_display,tag=zx.av_new,distance=0..,limit=1] item.components."minecraft:custom_data".zx_an set from storage zx:anchor new
scoreboard players set @e[type=minecraft:item_display,tag=zx.av_new,distance=0..,limit=1] zx.av_phase 0
scoreboard players set @e[type=minecraft:item_display,tag=zx.av_new,distance=0..,limit=1] zx.av_t 0
scoreboard players set @e[type=minecraft:item_display,tag=zx.av_new,distance=0..,limit=1] zx.av_life 0
tag @e[type=minecraft:item_display,tag=zx.av_new,distance=0..] remove zx.av_new
