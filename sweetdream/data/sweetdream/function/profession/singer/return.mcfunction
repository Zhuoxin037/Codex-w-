data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,scores={zx.job=3}] run return run kill @s
execute if entity @a[tag=zx.ub,distance=..1.5] run return run function sweetdream:profession/singer/refund
execute facing entity @a[tag=zx.ub,limit=1] feet positioned ^ ^ ^0.6 run tp @s ~ ~ ~
