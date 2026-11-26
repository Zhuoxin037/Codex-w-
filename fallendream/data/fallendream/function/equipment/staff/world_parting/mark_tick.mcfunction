data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute unless entity @a[tag=zx.ub,scores={zx.job=4},distance=0..,limit=1] run return run kill @s
function fallendream:equipment/staff/world_parting/mark_follow with entity @s data
execute unless entity @s[tag=zx.wp_mark] run return 0
execute at @s run function fallendream:equipment/staff/world_parting/mark_check
execute unless score @s zx.wp_red > #now manacore.meta unless score @s zx.wp_white > #now manacore.meta unless score @s zx.wp_gate > #now manacore.meta run kill @s
