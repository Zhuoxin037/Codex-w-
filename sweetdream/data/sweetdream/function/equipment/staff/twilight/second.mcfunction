# ============================================================
# sweetdream:equipment/staff/twilight/second —— 暮光的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 服务器身份)
# 【内容】每个带 zx.tw_tgt 的目标生物: tw_tick(维持抗性失效 + 倒计时)
# 【★ 裸 @e 在这里是安全的】event/second 每秒只跑一次。
# ============================================================

execute as @e[tag=zx.tw_tgt] at @s run function sweetdream:equipment/staff/twilight/tw_tick
