execute if score @s zx.nr_due > #now manacore.meta run return 0
data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
scoreboard players operation #nr_hit_tick zx.meta = @s zx.nr_tick
execute unless entity @a[tag=zx.ub,scores={zx.job=2},distance=0..,limit=1] run return run kill @s
execute as @a[tag=zx.ub,scores={zx.job=2},distance=0..,limit=1] if score @s zx.nr_reject = #nr_hit_tick zx.meta run scoreboard players set #nr_abort zx.meta 1
execute as @a[tag=zx.ub,scores={zx.job=2},distance=0..,limit=1] unless score @s zx.nr_reject = #nr_hit_tick zx.meta run scoreboard players set #nr_abort zx.meta 0
execute if score #nr_abort zx.meta matches 1 run return run kill @s
tag @e[tag=zx.nr_target,distance=0..] remove zx.nr_target
scoreboard players set #nr_steps zx.meta 0
function sweetdream:equipment/axe/no_return/blade_ray
execute as @a[tag=zx.ub,scores={zx.job=2},distance=0..,limit=1] positioned ~ ~ ~ run function sweetdream:equipment/axe/no_return/blade_damage
tag @e[tag=zx.nr_target,distance=0..] remove zx.nr_target
kill @s
