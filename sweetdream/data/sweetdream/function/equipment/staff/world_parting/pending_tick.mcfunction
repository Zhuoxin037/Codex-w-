execute if score @s zx.wp_due > #now manacore.meta run return 0
data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,scores={zx.job=4},distance=0..,limit=1] run return run kill @s
function sweetdream:equipment/staff/world_parting/pending_hit with entity @s data
kill @s
