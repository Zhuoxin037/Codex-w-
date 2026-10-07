# ============================================================
# sweetdream:equipment/tool/wrath/second —— 愠怒的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 服务器身份)
# 【文案】持于副手时，若自身血量低于 20%，则自身获得**常态**的抗性提升Ⅰ，
#   之后自身有关最大魔力值的技能伤害提升 20%（独立乘区）。
# 【"常态"怎么实现】每秒判一次血量 -> 有就续 2 秒抗性 / 没有就不续(自然过期)。
#   照文案注释"别写成一次性给"。续 2 秒是为了扛住每秒只判一次的空档。
# 【伤害那半见 hook_calc —— 挂 damage_calc 事件, 这里只管抗性】
# ============================================================

function sweetdream:lib/in_bak

execute as @a at @s run function sweetdream:equipment/tool/wrath/second_one

function sweetdream:lib/in_restore
