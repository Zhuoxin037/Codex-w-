# ============================================================
# sweetdream:equipment/armor/bearing/attr_tou —— 换"护甲韧性"档（#br_n = 层数）
# ------------------------------------------------------------
# 【★ 字面量禁区 ★】0/1/2/3 三档（0 层不挂）各写一条。
# ============================================================

execute if score @s zx.br_t matches 1.. run attribute @s minecraft:armor_toughness modifier remove sweetdream:br_tou
scoreboard players set @s zx.br_t 0
execute if score #br_n zx.meta matches 1 run attribute @s minecraft:armor_toughness modifier add sweetdream:br_tou 1 add_value
execute if score #br_n zx.meta matches 2 run attribute @s minecraft:armor_toughness modifier add sweetdream:br_tou 2 add_value
execute if score #br_n zx.meta matches 3 run attribute @s minecraft:armor_toughness modifier add sweetdream:br_tou 3 add_value
scoreboard players operation @s zx.br_t = #br_n zx.meta
