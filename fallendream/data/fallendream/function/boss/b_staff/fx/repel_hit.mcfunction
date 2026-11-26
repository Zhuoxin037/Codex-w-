function fallendream:boss/b_staff/fx/repel_particles
data merge entity @s {start_interpolation:0,transformation:{scale:[0.25f,1f,0.25f]}}
scoreboard players set #radius bs.r2 62500
function fallendream:boss/b_staff/area/hit
