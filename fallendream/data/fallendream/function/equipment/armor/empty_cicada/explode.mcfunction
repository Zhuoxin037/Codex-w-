execute unless entity @s[tag=zx.s2_cicada] run return 0
execute unless score @s zx.s2_end > #now manacore.meta run return run kill @s
tag @s remove zx.s2_cicada
data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute as @a[tag=zx.ub,distance=0..,limit=1] positioned ~ ~ ~ run function fallendream:equipment/armor/empty_cicada/damage
effect give @e[type=!#fallendream:no_damage,distance=..3] minecraft:weakness 3 1 true
particle minecraft:cloud ~ ~.8 ~ .9 .5 .9 0.04 32 normal

# 超限·空蝉：吸引 + 起终点各补一个 30 秒的额外余影（本体标记在 marker 的 data.ol 上）
execute if data entity @s data.ol run function fallendream:equipment/armor/empty_cicada/ol_after
kill @s
