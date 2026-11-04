execute unless entity @s[tag=zx.ff_particle] run return 0
tag @s remove zx.ff_particle
tag @s remove zx.ff_fly
data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
tag @e[type=!#sweetdream:no_damage,distance=..1] add zx.ff_hit
execute as @a[tag=zx.ub,distance=0..,limit=1] positioned ~ ~ ~ run function sweetdream:equipment/staff/firefly_staff/damage
tag @e[tag=zx.ff_hit,distance=0..] remove zx.ff_hit
particle minecraft:glow ~ ~ ~ 0.3 0.3 0.3 0.03 12 normal
kill @s
