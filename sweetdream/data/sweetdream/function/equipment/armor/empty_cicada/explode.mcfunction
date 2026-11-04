execute unless entity @s[tag=zx.s2_cicada] run return 0
execute unless score @s zx.s2_end > #now manacore.meta run return run kill @s
tag @s remove zx.s2_cicada
data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,distance=0..,limit=1] positioned ~ ~ ~ run function sweetdream:equipment/armor/empty_cicada/damage
effect give @e[type=!#sweetdream:no_damage,distance=..3] minecraft:weakness 3 1 true
particle minecraft:cloud ~ ~.8 ~ .9 .5 .9 0.04 32 normal
kill @s
