# ============================================================
# core/tick —— 每 tick 主循环
# ------------------------------------------------------------
# 【触发】data/minecraft/tags/function/tick.json, 每游戏刻执行一次。
# 【做了什么】
#   #now   : 框架自己的"游戏刻时钟"。用它而不是 /time query gametime,
#            好处是冷却/术阵到期时间全部落在同一套时间轴上, 且不掉帧。
#            #now 的值会被世界存档保存, 重启后继续累加, 所以冷却不会因
#            重启而错乱。
#   #tick  : 秒计数器, 累加到 #interval(默认 20) 时触发 core/second。
# 【性能】每 tick 只有 3 条命令, 玩家逻辑全部放在"每秒"里做, 所以多人在线
#         也不会因为框架本身掉 TPS。
# 【想改频率】/data modify storage manacore:config settings.regen_interval
#         然后 /reload(或直接改 #interval 计分板)。
# ============================================================

# --- 自愈: 确保计分板目标与初始化一定完成 ---
# 这几行必须放在最前面: 如果目标还没建好, 下面的主循环会直接报错中断。
# 平时它们只是几次存在性判断, 开销可以忽略。
execute unless data storage manacore:config inited run function manacore:core/init
scoreboard players add #boot_done manacore.meta 0
execute if score #boot_done manacore.meta matches 0 run function manacore:core/boot

# --- 主循环 ---
scoreboard players add #now manacore.meta 1
scoreboard players add #tick manacore.timer 1
execute if score #tick manacore.timer >= #interval manacore.meta run function manacore:core/second
