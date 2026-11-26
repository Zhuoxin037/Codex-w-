# ============================================================
# fallendream:equipment/armor/breath_hold/hook_calc —— 超限: 术阵位全满时技能伤害 +12%
# ------------------------------------------------------------
# @calc: add   ← 加算型: 只往加算池里写百分比, 由 lib/dmg_add_apply 统一乘
# 【谁调用它】#manacore:event/damage_calc —— 排在 lib/dmg_add_apply 之前
# 【文案】「术阵位全满时，改为每秒恢复 5 点魔力值，且自身技能伤害 +12%」
# 【口径】与「桂冠 / 愿景」同一套: 交给 lib/dmg_add_put_any 给三条通道各写一份,
#   整段技能伤害就是 +12%(见该函数头注的 D01 口径 B)。
# 【为什么每次结算现判】术阵位会变(建阵/拆阵), 伤害结算时读当前 fm_u/fm_c
#   才是"全满才算"; 不设窗口、不设倒计时。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["breath_hold"],ol:"breath_hold"}] run return 0
execute unless score @s zx.fm_u >= @s zx.fm_c run return 0

scoreboard players set #pct zx.meta 12
execute store result storage zx:work put.pct int 1 run scoreboard players get #pct zx.meta
function fallendream:lib/dmg_add_put_any
