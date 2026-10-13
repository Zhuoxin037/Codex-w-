# ============================================================
# sweetdream:equipment/staff/chime/is_ol —— 「共鸣」手里这把是不是超限版
# ------------------------------------------------------------
# 【谁调用它】chime/skill(施法那刻判一次)
# 【出参】#ch_ol zx.meta: 1 = 主手这把是「超限·共鸣」, 0 = 原版
# 【判据】主手物品的 custom_data 同时带 zx:["chime"] 与 ol:"chime"
# 【为什么 skill 里现判就够】四处分档(每秒段倍率 / 穿过段倍率与半径 / 水晶寿命 /
#   自毁伤害)全都由**水晶**带着走 —— skill 判一次, 把结论写进水晶的 data.zx.ch.ol,
#   之后各处读水晶即可, 不需要玩家侧的跨刻快照。
# ============================================================

scoreboard players set #ch_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["chime"],ol:"chime"}] run scoreboard players set #ch_ol zx.meta 1
