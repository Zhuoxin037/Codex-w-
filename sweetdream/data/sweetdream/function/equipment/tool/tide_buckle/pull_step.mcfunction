# 距离不足一步时停下；绝不越过圆心再向外移动。
execute at @e[tag=zx.tb_center,distance=0..,limit=1] unless entity @s[distance=0.25..] run return 0
execute at @s facing entity @e[tag=zx.tb_center,distance=0..,limit=1] feet positioned ^ ^ ^0.25 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ~ ~ ~
