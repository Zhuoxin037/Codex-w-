# ============================================================
# sweetdream:equipment/staff/fallen_dream/second —— 堕梦时停 DoT 的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 全局身份)
# 【从目标侧驱动】DoT 的状态(tag zx.fd_t + data.zx.fd)全在生物身上,
#   多个玩家同时放各结各的, 互不串。
# 【备份公共输入口】one 里要调 mana/get(写 manacore:in arg), 见 lib/in_bak。
# ============================================================

function sweetdream:lib/in_bak

execute as @e[tag=zx.fd_t] at @s run function sweetdream:equipment/staff/fallen_dream/one

function sweetdream:lib/in_restore
