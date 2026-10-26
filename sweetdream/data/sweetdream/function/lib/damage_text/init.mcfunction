$data merge entity @s {Tags:["zx.damage_text"],text:{text:"$(value)",color:"gold",bold:true},billboard:"center",background:0,shadow:1b,see_through:0b,text_opacity:-1b,view_range:1.0f,teleport_duration:1,brightness:{block:15,sky:15},transformation:{translation:[0f,0f,0f],scale:[0.65f,0.65f,0.65f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}
scoreboard players operation @s zx.dt_end = #now manacore.meta
scoreboard players add @s zx.dt_end 30
scoreboard players add #dt_count zx.meta 1
