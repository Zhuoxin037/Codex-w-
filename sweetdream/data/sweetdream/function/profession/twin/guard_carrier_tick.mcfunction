data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,scores={zx.job=4,zx.j_form=1}] run kill @s
