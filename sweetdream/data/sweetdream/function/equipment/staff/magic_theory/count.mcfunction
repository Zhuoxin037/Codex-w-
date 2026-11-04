scoreboard players set #s2_rail_hits zx.meta 0
$execute store result score #s2_rail_hits zx.meta run data get storage zx:b21 rails."$(owner)"."$(target)"
scoreboard players add #s2_rail_hits zx.meta 1
$execute store result storage zx:b21 rails."$(owner)"."$(target)" int 1 run scoreboard players get #s2_rail_hits zx.meta
execute unless score #s2_rail_hits zx.meta matches 3 run return 0
data modify storage zx:work ub set from storage zx:work s2_rail
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] positioned ~ ~ ~ run function sweetdream:equipment/staff/magic_theory/burst
