tag @e[tag=zx.j_follow_v,distance=0..16] remove zx.j_follow_v
tag @e[type=!#sweetdream:no_damage,distance=..3] add zx.j_follow_v
execute at @a[tag=zx.j_ally_cast,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=..3] add zx.j_follow_v
data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,scores={zx.job=3},limit=1] positioned ~ ~ ~ run function sweetdream:profession/singer/damage
tag @e[tag=zx.j_follow_v,distance=0..16] remove zx.j_follow_v
