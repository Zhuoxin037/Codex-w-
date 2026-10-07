# ============================================================
# sweetdream:equipment/armor/stellar_elegy/is_ol —— 这件是不是**超限版**
# ------------------------------------------------------------
# 【出参】#se_ol zx.meta = 1 / 0   【执行者】玩家
# 【判定】部分匹配 + 独有标记 + ol 字段(敲上超限石后由 station 写进 custom_data)。
#   ⚠️ 用 ~ 而不是 = : 多一段少一段就静默失效(踩过两次)。
# 【为什么单独一个文件】超限版要改的地方有四处(passive / hurt / aoe / regen),
#   每处都手抄一遍这段谓词, 改的时候必然漏掉一处 —— "改了三处、第四处还是旧行为"
#   是最难查的那类 bug。
# 【★ 判定只看"穿在身上的这件" ★】同一件装备脱下来再穿、或换一件没超限的同名
#   装备, 下一秒自动变回原版数值(所有落地都是"目标值 - 账本"的差值制)。
# ============================================================

scoreboard players set #se_ol zx.meta 0
execute if items entity @s armor.legs netherite_leggings[custom_data~{zx:["stellar_elegy"],ol:"stellar_elegy"}] run scoreboard players set #se_ol zx.meta 1
