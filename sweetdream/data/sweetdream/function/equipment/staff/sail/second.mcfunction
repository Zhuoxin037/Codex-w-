# ============================================================
# sweetdream:equipment/staff/sail/second —— 风帆的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 服务器身份)
# 【内容】
#   · 每个旋风: whirl_tick(每 3 秒脉冲 + 倒计时 + 表现)
#   · 每个"旋风进行中"的玩家: own_tick(把 zx.sl_vt 倒计时, 供"再次使用技能"识别)
# 【★ 裸 @e 在这里是安全的】event/second 每秒只跑一次。
# ============================================================

function sweetdream:lib/in_bak

execute as @e[tag=zx.sl_vtx] at @s run function sweetdream:equipment/staff/sail/whirl_tick
execute as @a[scores={zx.sl_vt=1..}] at @s run function sweetdream:equipment/staff/sail/own_tick

function sweetdream:lib/in_restore
