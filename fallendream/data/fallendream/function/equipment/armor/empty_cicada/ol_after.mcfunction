# 面向余影沿正Z靠近；距离不足3格时直接到圆心，避免越过圆心。
tag @s add zx.cic_pull
execute as @e[type=!#fallendream:no_damage,tag=!zx.cic_pull,distance=..3] at @s run function fallendream:equipment/armor/empty_cicada/pull_one
tag @s remove zx.cic_pull
particle minecraft:cloud ~ ~0.5 ~ 0.8 0.3 0.8 0.02 16 normal
