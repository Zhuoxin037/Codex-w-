# ============================================================
# sweetdream:equipment/axe/skyvault/rise_end —— 跃升到顶(执行者 = 玩家)
# ------------------------------------------------------------
# 【谁调用它】core/tick: zx.sv_rise 超过 10 的那一 tick
# 【做什么】摘跃升标记 -> 进入"可俯冲"窗口(zx.sv_air)。
#   【★ 二段还要等几 tick 才解锁, 由 zx.sv_launch 决定 ★】
#     2026-10-04 玩家要求"二段 0.5 秒后可用" —— 而跃升本身就要 10 刻(0.5 秒),
#     所以这里设 **0 = 跃升到顶的那一刻就能俯冲**, 总时长正好 0.5 秒, 和描述一致。
#     以后想再拉开"到顶 -> 可俯冲"的间隔, 就把 0 改成想要的 tick 数
#     (20 = 1 秒), **并同步改 give 里那句"X 秒后"的描述**。
# ============================================================

tag @s remove zx.sv_rising
scoreboard players reset @s zx.sv_rise
tag @s add zx.sv_air
scoreboard players set @s zx.sv_launch 0
execute at @s run particle minecraft:end_rod ~ ~1 ~ 0.8 0.5 0.8 0.05 24 normal
execute at @s run particle minecraft:cloud ~ ~1 ~ 0.8 0.4 0.8 0.03 16 normal
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.6 1.6
