# ============================================================
# sweetdream:equipment/armor/intent/second —— 「蓄意」常驻生命上限 +20%
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】魔力 +150（armor_mana 登记），最大生命值 +20%。
#   每使用 50 魔力 → +2 临时生命（intent/tick 每刻结算）。
#   临时生命清空 → 5 秒抗性Ⅱ + 迅捷Ⅲ，12 秒冷却（intent/on_empty）。
# 【★ "+20%" 用 add_multiplied_total ★】基数是玩家**原版**最大生命（20 点），
#   与包内其它百分比生命加成同一口径。
# ============================================================

execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["intent"]}] run function sweetdream:equipment/armor/intent/off
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["intent"]}] run return 0

execute unless score @s zx.it_hp matches 1 run attribute @s minecraft:max_health modifier add sweetdream:it_hp 0.2 add_multiplied_total
execute unless score @s zx.it_hp matches 1 run scoreboard players set @s zx.it_hp 1
