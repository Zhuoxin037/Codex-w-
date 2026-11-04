data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,scores={zx.job=3},distance=0..,limit=1] positioned ~ ~ ~ run function sweetdream:equipment/staff/chorus/damage
