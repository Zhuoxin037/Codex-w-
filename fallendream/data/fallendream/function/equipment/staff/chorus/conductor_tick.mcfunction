data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute unless entity @a[tag=zx.ub,scores={zx.job=3},distance=0..,limit=1] run return run kill @s
scoreboard players remove @s zx.cs_left 1
execute if score @s zx.cs_left matches 180 run function fallendream:equipment/staff/chorus/beat with entity @s data
execute if score @s zx.cs_left matches 120 run function fallendream:equipment/staff/chorus/beat with entity @s data
execute if score @s zx.cs_left matches 60 run function fallendream:equipment/staff/chorus/beat with entity @s data
execute if score @s zx.cs_left matches 0 run function fallendream:equipment/staff/chorus/beat with entity @s data
execute if score @s zx.cs_left matches ..0 run function fallendream:equipment/staff/chorus/finish with entity @s data
