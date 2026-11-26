execute unless entity @s[tag=zx.ex_big] run return 0
tag @s remove zx.ex_big
data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute as @a[tag=zx.ub,distance=0..,limit=1] positioned ~ ~ ~ run function fallendream:equipment/staff/exalted/explosion_damage
particle minecraft:large_smoke ~ ~ ~ 0.7 0.7 0.7 0.02 20 normal
# 本体 + 外观载体一起收(只 kill marker 的话石像会留在原地不动, 见 big_die 头部)
function fallendream:equipment/staff/exalted/big_die
