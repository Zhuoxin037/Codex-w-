# ============================================================
# sweetdream:equipment/armor/rain_trace/pay_one —— 这只生物停够 2 秒了吗（执行者 = 生物）
# ------------------------------------------------------------
# 【谁调用它】pay ①
# 【判据】#now - zx.rt_first >= 40 刻（2 秒）→ 打标签 zx.rt_pay
# 【★ 为什么不用选择器直接筛 ★】选择器比不了"两个计分项的差"，只能逐只判。
#   被遍历的只有"当前在水迹里"的生物（scores={zx.rt_on=1}），量很小。
# ============================================================

scoreboard players operation #rt_age zx.meta = #now manacore.meta
scoreboard players operation #rt_age zx.meta -= @s zx.rt_first
execute if score #rt_age zx.meta matches 40.. run tag @s add zx.rt_pay
