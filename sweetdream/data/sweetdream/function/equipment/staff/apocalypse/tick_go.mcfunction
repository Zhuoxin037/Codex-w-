# ============================================================
# sweetdream:equipment/staff/apocalypse/tick_go —— 灾示状态的一秒
# ------------------------------------------------------------
# 【谁调用它】tick_s(执行者 = 灾示状态中的玩家, at @s)
# 【顺序】先干活(t3 灾示 / t4 换页)再扣状态 —— 状态归零的那一秒清计时器,
#   不影响本秒已触发的灾示; 下一秒起选择器筛不到人, 自然停。
# ============================================================

# ① 灾示计时: 每 3 秒一次(到点 reveal, 里头会把 t3 重置回 3)
scoreboard players remove @s zx.ap_t3 1
execute if score @s zx.ap_t3 matches ..0 run function sweetdream:equipment/staff/apocalypse/reveal

# ② 换页计时: 每 4 秒消耗一页(到点 page_tick, 有页才真消耗)
scoreboard players remove @s zx.ap_t4 1
execute if score @s zx.ap_t4 matches ..0 run function sweetdream:equipment/staff/apocalypse/page_tick

# ③ 状态倒计时
scoreboard players remove @s zx.ap_on 1
execute if score @s zx.ap_on matches ..0 run function sweetdream:equipment/staff/apocalypse/end_state
