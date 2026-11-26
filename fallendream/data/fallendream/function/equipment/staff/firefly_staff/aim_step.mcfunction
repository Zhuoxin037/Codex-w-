execute positioned ~-0.5 ~-0.5 ~-0.5 as @e[type=!#fallendream:no_damage,dx=0,dy=0,dz=0,sort=nearest,limit=1] if data entity @s Health unless data entity @s {Health:0.0f} run function fallendream:equipment/staff/firefly_staff/aim_capture
execute if data storage zx:work firefly.target run return 1
scoreboard players add #ff_ray zx.meta 1
execute if score #ff_ray zx.meta matches ..47 positioned ^ ^ ^0.25 run function fallendream:equipment/staff/firefly_staff/aim_step
