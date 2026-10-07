# ============================================================
# sweetdream:equipment/staff/gu_poison/second —— 蛊毒的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 服务器身份)
# 【内容】每个带 zx.gp_tgt 的目标生物: gp_tick(每秒结算 / 查噬心 / 倒计时)
# 【★ 裸 @e 在这里是安全的】event/second 每秒只跑一次(不是"每维度各跑一次")。
# ============================================================

function sweetdream:lib/in_bak

execute as @e[tag=zx.gp_tgt] at @s run function sweetdream:equipment/staff/gu_poison/gp_tick

function sweetdream:lib/in_restore
