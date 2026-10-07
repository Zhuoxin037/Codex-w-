# distance=0.. 将选择器限定到当前执行维度，避免三维度循环重复处理同一实体。
# 先标为未认领，再让活体续租；死亡或旧维度残留在本轮收掉。
scoreboard players set @e[distance=0..,type=minecraft:text_display,tag=zx.icon_v2] zx.icon_ttl 0
# 标签剩余秒数(每秒 -1, 归零自动摘标签 —— 见 tag/ttl_tick)。
#   放在 icon_refresh 之前: 到期的标签先被摘掉并刷新图标, 这一轮就顺手把图标淡出。
execute as @e[distance=0..,tag=zx.tagged] at @s run function sweetdream:tag/ttl_tick
execute as @e[distance=0..,tag=zx.tagged] at @s run function sweetdream:tag/icon_refresh
kill @e[distance=0..,type=minecraft:text_display,tag=zx.icon_v2,scores={zx.icon_ttl=0}]
# 迁移结束后清理当前已加载的旧显示实体；不强制加载远处区块。
#   ★ 必须排除 zx.icon_fading: 正在淡出的图标已经摘掉了 zx.icon_v2, 不排除的话
#     会被这条"旧格式清理"当场杀掉, 淡出永远只播一帧。
kill @e[distance=0..,type=minecraft:text_display,tag=zx.icon,tag=!zx.icon_v2,tag=!zx.icon_fading]
