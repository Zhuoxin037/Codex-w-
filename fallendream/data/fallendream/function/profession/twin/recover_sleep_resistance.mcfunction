effect clear @s minecraft:resistance
effect give @s minecraft:resistance infinite 1 true
data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute if entity @a[tag=zx.ub,scores={zx.job=4,zx.j_aw=1},limit=1] run effect give @s minecraft:resistance infinite 2 true
