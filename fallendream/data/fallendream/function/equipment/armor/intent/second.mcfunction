# ============================================================
# fallendream:equipment/armor/intent/second —— 「蓄意」常驻生命上限
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】基础: 魔力 +150（armor_mana 登记），最大生命值 +20%；
#        超限: 魔力 +200，最大生命值 +30%（2026-11-22）。
#   每使用 50 魔力 → +2 临时生命（intent/tick 每刻结算）。
#   临时生命清空 → 基础 5 秒抗性Ⅱ + 迅捷Ⅲ、12 秒冷却（intent/on_empty）；
#        超限走 intent/ol_empty 的三段式（7 秒 → 额外 10 秒 → 刷新）。
# 【★ "+N%" 用 add_multiplied_total ★】基数是玩家**原版**最大生命（20 点），
#   与包内其它百分比生命加成同一口径。
# 【★ modifier 不能改数值, 只能摘了重挂 ★】所以 zx.it_hp 存的是"当前挂的是哪一档"
#   (0 没挂 / 1 = +20% / 2 = +30%), 换档那一刻才 remove + add。
#   ★ modifier 数值是字面量 ⇒ 每档必须各写一条 add（不能拿分数当参数）。
# 【★ 额外层的 +10%（fallendream:it_hp2）在这里收 ★】它跟 zx.it_b_end 同寿;
#   effect 形式的抗性Ⅳ 由原版自己到期, 只有 modifier 不会自己消失。
# ============================================================

execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["intent"]}] run function fallendream:equipment/armor/intent/off
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["intent"]}] run return 0

scoreboard players set #it_want zx.meta 1
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["intent"],ol:"intent"}] run scoreboard players set #it_want zx.meta 2

scoreboard players add @s zx.it_hp 0
execute unless score @s zx.it_hp = #it_want zx.meta run attribute @s minecraft:max_health modifier remove fallendream:it_hp
execute unless score @s zx.it_hp = #it_want zx.meta if score #it_want zx.meta matches 1 run attribute @s minecraft:max_health modifier add fallendream:it_hp 0.2 add_multiplied_total
execute unless score @s zx.it_hp = #it_want zx.meta if score #it_want zx.meta matches 2 run attribute @s minecraft:max_health modifier add fallendream:it_hp 0.3 add_multiplied_total
execute unless score @s zx.it_hp = #it_want zx.meta run scoreboard players operation @s zx.it_hp = #it_want zx.meta

execute if score @s zx.it_b_end matches 1.. unless score @s zx.it_b_end > #now manacore.meta run attribute @s minecraft:max_health modifier remove fallendream:it_hp2
execute if score @s zx.it_b_end matches 1.. unless score @s zx.it_b_end > #now manacore.meta run scoreboard players set @s zx.it_b_end 0
