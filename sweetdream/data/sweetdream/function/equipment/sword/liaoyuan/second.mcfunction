# ============================================================
# sweetdream:equipment/sword/liaoyuan/second —— 每秒入口(挂在 #manacore:event/second)
# ------------------------------------------------------------
# 【★ 必须 at @s ★】只写 execute as 的话位置还是服务器的, 里面所有"自身 5 格内"都会算错。
# 【备份公共输入口】pulse 里要读魔力/算伤害, 会写 manacore:in arg, 见 lib/in_bak。
# 【开销】只有光环还在(ly_aura >= 1)的人参与, 平时为零。
# ============================================================

function sweetdream:lib/in_bak

execute as @a[scores={zx.ly_aura=1..}] at @s run function sweetdream:equipment/sword/liaoyuan/second_one

function sweetdream:lib/in_restore
