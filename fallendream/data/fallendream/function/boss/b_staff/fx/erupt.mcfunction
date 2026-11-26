data modify entity @s item.components."minecraft:item_model" set value "fallendream_boss:b_staff/fx_beam"
data merge entity @s {start_interpolation:0,transformation:{scale:[1f,0.1f,1f],translation:[0f,0.09375f,0f]}}
scoreboard players set #radius bs.r2 22500
function fallendream:boss/b_staff/area/hit
