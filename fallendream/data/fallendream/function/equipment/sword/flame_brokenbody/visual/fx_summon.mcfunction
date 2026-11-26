tag @e[type=minecraft:item_display,tag=zx.fb_fx_new,distance=0..] remove zx.fb_fx_new
$summon minecraft:item_display ~ ~ ~ {Tags:["zx.fb_fx","zx.fb_fx_$(uuid)","zx.fb_fx_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"flameremnant:flame_wave","minecraft:custom_model_data":{floats:[0.0f]},"minecraft:custom_data":{}}},item_display:"fixed",billboard:"fixed",brightness:{block:15,sky:15},teleport_duration:1,interpolation_duration:0,width:14.0f,height:4.0f,view_range:1.0f,shadow_radius:0.0f}
data modify entity @e[type=minecraft:item_display,tag=zx.fb_fx_new,distance=0..,limit=1] item.components."minecraft:custom_data".zx_fb set from storage zx:fbvis owner
data modify entity @e[type=minecraft:item_display,tag=zx.fb_fx_new,distance=0..,limit=1] Rotation[0] set from storage zx:fbvis owner.yaw
scoreboard players set @e[type=minecraft:item_display,tag=zx.fb_fx_new,distance=0..,limit=1] zx.fb_fx_t 0
tag @e[type=minecraft:item_display,tag=zx.fb_fx_new,distance=0..] remove zx.fb_fx_new
