# ============================================================
# sweetdream:equipment/sword/deepsea_echo/is_ol —— 手里这把是不是**超限版**
# ------------------------------------------------------------
# 【出参】#de_ol zx.meta = 1 / 0   【执行者】玩家
# 【★ 主手 + 副手都判 ★】技能是右键消耗触发的, 剑可能在副手。
# 【★ 只判"手上", 不判物品栏 ★】
#   本函数的用途是"这一次施法按哪套数值结算"(倍率 / 范围 / 耗蓝 / 渊海加成)。
#   文案里"在自身物品栏里时给水下呼吸"是**另一条**(被动), 它走 passive 里的
#   clear 计数 —— 那条才需要扫背包。这里若也扫背包, 手上拿着基础版、背包里
#   躺着超限版时会误按超限结算。
# ============================================================

scoreboard players set #de_ol zx.meta 0
execute if items entity @s weapon.mainhand *[custom_data~{zx:["deepsea_echo"],ol:"deepsea_echo"}] run scoreboard players set #de_ol zx.meta 1
execute if items entity @s weapon.offhand *[custom_data~{zx:["deepsea_echo"],ol:"deepsea_echo"}] run scoreboard players set #de_ol zx.meta 1
