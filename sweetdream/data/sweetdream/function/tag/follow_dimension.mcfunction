# distance=0.. 将选择器限定到当前执行维度，避免三维度循环重复处理同一实体。
# 只遍历自己的图标和被标记的生物。租约负责死亡、卸载边界与跨维度残留。
scoreboard players remove @e[distance=0..,type=minecraft:text_display,tag=zx.icon_v2] zx.icon_ttl 2
execute as @e[distance=0..,tag=zx.tagged] at @s unless data entity @s {Health:0.0f} run function sweetdream:tag/follow_one
kill @e[distance=0..,type=minecraft:text_display,tag=zx.icon_v2,scores={zx.icon_ttl=..0}]
