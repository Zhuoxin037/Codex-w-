execute if score @s zx.ws_due > #now manacore.meta run return 0
data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute unless entity @a[tag=zx.ub,scores={zx.job=2},distance=0..,limit=1] run kill @s
execute unless entity @s run return 0
function fallendream:equipment/sword/wound_stitch/delay_hit with entity @s data
kill @s
