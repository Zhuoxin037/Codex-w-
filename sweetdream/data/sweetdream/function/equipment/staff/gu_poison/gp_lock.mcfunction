# ============================================================
# sweetdream:equipment/staff/gu_poison/gp_lock —— 给一个「噬心」目标挂上本轮参数
# ------------------------------------------------------------
# 【谁调用它】skill 第 ⑧ 步(execute as @e[tag=zx.gp_tgt] run ...); 【执行者】目标生物
# 【参数来源】zx:work gp = {uuid,u0..u3}(释放者), 整份抄进 data.zx.gp(不用宏)。
# 【倒计时】zx.gp_t = 6(秒), 由 second -> gp_tick 每秒 -1。
# ============================================================

data modify entity @s data.zx.gp set from storage zx:work gp
scoreboard players set @s zx.gp_t 6
