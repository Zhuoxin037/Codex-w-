# 先标为未认领，再让活体续租；死亡或旧维度残留在本轮收掉。
scoreboard players set @e[type=minecraft:text_display,tag=zx.icon_v2] zx.icon_ttl 0
execute as @e[tag=zx.tagged] at @s run function sweetdream:tag/icon_refresh
kill @e[type=minecraft:text_display,tag=zx.icon_v2,scores={zx.icon_ttl=0}]
# 迁移结束后清理当前已加载的旧显示实体；不强制加载远处区块。
kill @e[type=minecraft:text_display,tag=zx.icon,tag=!zx.icon_v2]
