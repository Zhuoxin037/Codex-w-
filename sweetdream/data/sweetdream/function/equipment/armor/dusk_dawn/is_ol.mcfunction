# ============================================================
# sweetdream:equipment/armor/dusk_dawn/is_ol —— 这件是不是**超限版**
# ------------------------------------------------------------
# 【出参】#dd_ol zx.meta = 1 / 0   【执行者】玩家
# 【为什么单独一个文件】超限版要改四处(passive / low_mana / kill / kill_mark_go),
#   每处手抄一遍谓词必然漏改 —— 统一的判据只写一份。
# 【★ 判定只看"穿在脚上的这件" ★】脱下来再穿一件没超限的同名靴子, 下一秒自动
#   变回原版数值(所有落地都是"目标值 - 账本"的差值制)。
# ============================================================

scoreboard players set #dd_ol zx.meta 0
execute if items entity @s armor.feet netherite_boots[custom_data~{zx:["dusk_dawn"],ol:"dusk_dawn"}] run scoreboard players set #dd_ol zx.meta 1
