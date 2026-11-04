scoreboard players add @s zx.ff_age 1
tag @a[tag=zx.ff_owner] remove zx.ff_owner
tag @a[tag=zx.ub,distance=0..,limit=1] add zx.ff_owner
tag @e[tag=zx.ff_hit,distance=0..] remove zx.ff_hit
execute positioned ~-0.4 ~-0.4 ~-0.4 run tag @e[type=!#sweetdream:no_damage,tag=!zx.ff_owner,dx=0.8,dy=0.8,dz=0.8] add zx.ff_hit
scoreboard players set #ff_touch zx.meta 0
execute if entity @e[tag=zx.ff_hit,distance=0..] run scoreboard players set #ff_touch zx.meta 1
tag @a[tag=zx.ff_owner] remove zx.ff_owner
execute if score #ff_touch zx.meta matches 1 run return run function sweetdream:equipment/staff/firefly_staff/explode
execute if score @s zx.ff_age matches 20.. run function sweetdream:equipment/staff/firefly_staff/explode
