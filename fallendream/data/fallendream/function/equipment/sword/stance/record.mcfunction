# ============================================================
# fallendream:equipment/sword/stance/record —— 窗口内累计"自身受到的伤害总量"
# ------------------------------------------------------------
# 【谁调用它】internal/hurt/event.mcfunction 的受伤事件串行分发链（需主对话加一行 hook）
#   建议：execute if score @s zx.hurt_evt matches 1.. run function fallendream:equipment/sword/stance/record
# 【执行者】受伤的玩家   【单位】zx.hurt_evt = 1 点血 1000（毫点定点）
# 【样板】equipment/sword/way_back/on_hurt.mcfunction（同样是 += zx.hurt_evt）
# 【门控】函数体内自带 zx.stc_on=1 判据；没开窗口时整段跳过
# ============================================================

execute unless score @s zx.stc_on matches 1 run return 0
scoreboard players operation @s zx.stc_sum += @s zx.hurt_evt
