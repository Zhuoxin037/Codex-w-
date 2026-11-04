data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,distance=0..,limit=1] run return run kill @s
execute if entity @s[tag=zx.ff_idle] run function sweetdream:equipment/staff/firefly_staff/follow with entity @s data
execute if entity @s[tag=zx.ff_fly] run function sweetdream:equipment/staff/firefly_staff/fly
execute if entity @s at @s run particle minecraft:glow ~ ~ ~ 0.04 0.04 0.04 0.002 1 normal
