# ============================================================
# sweetdream:equipment/axe/agony/second —— 苦痛的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 全局身份)
# 【为什么 as 目标跑】锁的状态(标签/结束时刻/释放者身份)全在**生物**身上,
#   从目标侧驱动天然按人分账 —— 多个玩家各锁各的、互不串。
#   伤害基数与归属也从目标身上的 data.zx.ag 读, 不依赖"谁在驱动"。
# 【备份公共输入口】one 里要调 stats/get(写 manacore:in arg), 见 lib/in_bak。
# ============================================================

function sweetdream:lib/in_bak

execute as @e[tag=zx.ag_t] at @s run function sweetdream:equipment/axe/agony/one

function sweetdream:lib/in_restore
