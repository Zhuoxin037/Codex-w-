# ============================================================
# sweetdream:equipment/armor/overflow/second —— 「溢流」常驻生命上限 +4
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】魔力 +80（armor_mana 登记），最大生命值 +4。
#   被过量治疗后 50% 溢出量转临时生命（hook 在 lib/heal 出口 → overflow/hook_heal）。
# 【★ 生命上限用 add_value 4 ★】不是百分比（"+20%" 那种才用 add_multiplied_total）。
# ============================================================

execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["overflow"]}] run function sweetdream:equipment/armor/overflow/off
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["overflow"]}] run return 0

execute unless score @s zx.ov_hp matches 1 run attribute @s minecraft:max_health modifier add sweetdream:ov_hp 4 add_value
execute unless score @s zx.ov_hp matches 1 run scoreboard players set @s zx.ov_hp 1
