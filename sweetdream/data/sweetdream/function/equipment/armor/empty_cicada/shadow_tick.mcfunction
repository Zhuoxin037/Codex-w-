execute unless score @s zx.s2_end > #now manacore.meta run return run kill @s
data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,distance=0..,limit=1] run return run kill @s
particle minecraft:dust{color:[0.65,0.75,0.9],scale:0.8} ~ ~.8 ~ .25 .7 .25 0 4 normal
