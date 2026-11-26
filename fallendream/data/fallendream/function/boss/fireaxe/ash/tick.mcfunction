scoreboard players add @s sdbf.death_age 1
execute rotated ~ 0 positioned ^ ^0.018 ^0.045 run tp @s ~ ~ ~ ~ 0
particle minecraft:dust{color:[0.38,0.36,0.33],scale:0.6} ~ ~ ~ 0.04 0.04 0.04 0.01 2 normal
execute if score @s sdbf.death_age matches 17 run data merge entity @s {start_interpolation:0,transformation:{scale:[0.08f,0.08f,0.08f]}}
execute if score @s sdbf.death_age matches 21 run data merge entity @s {start_interpolation:0,transformation:{scale:[0.035f,0.035f,0.035f]}}
execute if score @s sdbf.death_age matches 25.. run kill @s
