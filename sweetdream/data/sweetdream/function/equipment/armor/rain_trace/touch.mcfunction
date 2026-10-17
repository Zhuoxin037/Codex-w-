# ============================================================
# sweetdream:equipment/armor/rain_trace/touch —— 一只生物被水迹覆盖（执行者 = 生物）
# ------------------------------------------------------------
# 【谁调用它】dot_tick ②（对水迹 1.6 格内的每只生物）
# 【两个数】
#   zx.rt_first = **首次**进入这段水迹的刻      —— 拿来算"停留了多久"
#   zx.rt_end   = 最后一次被覆盖的刻 + 8        —— 容忍 0.4 秒的走位抖动
#   zx.rt_on    = 1 正在停留 / 2 本段已兑现 / 0 已离开
# 【★ 已经在水迹里（1 或 2）只刷新 rt_end ★】这样同一只生物被相邻两个水迹点
#   同时覆盖时，两次 touch 都是"刷新"，rt_first 不会被反复重置
#   （用 rt_t 每刻 +1 的写法就会被叠加成两倍速，那是错的）。
# ============================================================

# ① 已在里面（含已兑现的 2）→ 只刷新容忍到期刻
execute if score @s zx.rt_on matches 1.. run scoreboard players operation @s zx.rt_end = #now manacore.meta
execute if score @s zx.rt_on matches 1.. run scoreboard players add @s zx.rt_end 8

# ② 不在（0 / 没分数）→ 记首次进入刻，转入"停留中"
execute unless score @s zx.rt_on matches 1.. run scoreboard players operation @s zx.rt_first = #now manacore.meta
execute unless score @s zx.rt_on matches 1.. run scoreboard players operation @s zx.rt_end = #now manacore.meta
execute unless score @s zx.rt_on matches 1.. run scoreboard players add @s zx.rt_end 8
execute unless score @s zx.rt_on matches 1.. run scoreboard players set @s zx.rt_on 1
