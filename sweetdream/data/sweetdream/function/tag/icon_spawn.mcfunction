# 先用 ^ ^ ^ 真正把执行位置移到眼睛，再做世界竖直偏移。
# anchored eyes 直接搭配 ~ 坐标不会得到眼睛位置。
# 一行图标保持原来的单图标视觉尺寸；限制可见距离，不穿墙、不投影。
$execute at @s anchored eyes positioned ^ ^ ^ anchored feet positioned ~ ~0.45 ~ run summon minecraft:text_display ~ ~ ~ {Tags:["zx.icon","zx.icon_v2","zx.owner_$(u0)_$(u1)_$(u2)_$(u3)"],billboard:"center",see_through:0b,shadow:0b,background:0,default_background:0b,view_range:0.5f,line_width:200,brightness:{block:15,sky:15},teleport_duration:2,transformation:{translation:[0.0f,0.0f,0.0f],scale:[0.8f,0.8f,0.8f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]},text:{text:""}}
$scoreboard players set @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),limit=1] zx.icon_mask -1
