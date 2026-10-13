# ============================================================
# sweetdream:equipment/sword/tinder/is_ol —— 「火种」手里这把是不是超限版
# ------------------------------------------------------------
# 【谁调用它】tinder/hit(武器门控之后, 每次攻击判一次)
# 【出参】#td_ol zx.meta: 1 = 主/副手这把是「超限·火种」, 0 = 原版
# 【判据】物品的 custom_data 同时带 zx:["tinder"] 与 ol:"tinder"
#   ★ 主手**或**副手都算(火种本来就允许副手拿: hit 的门控就是两处都查)。
# 【为什么攻击时现判就够】三处分档(半径 2->3 / 当前魔力->最大魔力 / 夜火额外伤害)
#   全在**这一次攻击**里用完, 没有跨刻场景, 不需要快照。
#   ★ "熄灭与否"**不**是分档项: 两版都熄灭(2026-10-12 用户确认原稿漏写"并熄灭该武器")。
# ============================================================

scoreboard players set #td_ol zx.meta 0
execute if items entity @s weapon.mainhand netherite_sword[custom_data~{zx:["tinder"],ol:"tinder"}] run scoreboard players set #td_ol zx.meta 1
execute if items entity @s weapon.offhand netherite_sword[custom_data~{zx:["tinder"],ol:"tinder"}] run scoreboard players set #td_ol zx.meta 1
