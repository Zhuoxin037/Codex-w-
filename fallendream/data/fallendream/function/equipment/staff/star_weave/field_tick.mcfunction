data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute unless entity @a[tag=zx.ub,scores={zx.job=1},distance=0..,limit=1] run return run function fallendream:equipment/staff/star_weave/field_remove with entity @s data
execute unless score @s zx.weave_left matches 1.. run return run function fallendream:equipment/staff/star_weave/field_remove with entity @s data
scoreboard players remove @s zx.weave_clock 1
execute if score @s zx.weave_clock matches ..0 run function fallendream:equipment/staff/star_weave/pulse
