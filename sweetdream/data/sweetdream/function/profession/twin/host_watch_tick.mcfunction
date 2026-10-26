data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,scores={zx.job=4,zx.j_host_t=1..}] run kill @s
execute unless entity @s run return 0
function sweetdream:profession/twin/host_watch_go with entity @s data
