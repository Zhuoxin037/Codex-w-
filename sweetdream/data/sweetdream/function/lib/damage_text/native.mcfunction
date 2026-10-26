execute unless data storage zx:config damage_text{enabled:1b} run return 0
execute unless score @s zx.dt_hp matches 0.. run return 0
scoreboard players operation #dt_hp zx.meta = @s zx.dt_hp
scoreboard players operation #dt_ab zx.meta = @s zx.dt_ab
scoreboard players operation #dt_hp zx.meta -= #nh_hp zx.meta
scoreboard players operation #dt_ab zx.meta -= #nh_ab zx.meta
execute if score #dt_hp zx.meta matches ..-1 run scoreboard players set #dt_hp zx.meta 0
execute if score #dt_ab zx.meta matches ..-1 run scoreboard players set #dt_ab zx.meta 0
scoreboard players operation #dt_amount zx.meta = #dt_hp zx.meta
scoreboard players operation #dt_amount zx.meta += #dt_ab zx.meta
scoreboard players operation @s zx.dt_hp = #nh_hp zx.meta
scoreboard players operation @s zx.dt_ab = #nh_ab zx.meta
execute if score #dt_amount zx.meta matches 1.. run function sweetdream:lib/damage_text/show
