data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,distance=0..,limit=1] run return run kill @s
execute rotated as @a[tag=zx.ub,distance=0..,limit=1] run tp @s ~ ~ ~ ~ ~
scoreboard players set @s zx.ff_age 0
tag @s remove zx.ff_idle
tag @s add zx.ff_fly
