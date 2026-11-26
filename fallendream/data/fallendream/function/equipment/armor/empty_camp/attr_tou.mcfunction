# ============================================================
# fallendream:equipment/armor/empty_camp/attr_tou —— 换韧性档（0.5 / 1.0 / … / 3.0）
# ------------------------------------------------------------
# 【★ 字面量禁区 ★】六条分支各写一条；0 层不挂。
# ============================================================

execute if score @s zx.ec_t matches 1.. run attribute @s minecraft:armor_toughness modifier remove fallendream:ec_tou
scoreboard players set @s zx.ec_t 0
execute if score #ec_n zx.meta matches 1 run attribute @s minecraft:armor_toughness modifier add fallendream:ec_tou 0.5 add_value
execute if score #ec_n zx.meta matches 2 run attribute @s minecraft:armor_toughness modifier add fallendream:ec_tou 1.0 add_value
execute if score #ec_n zx.meta matches 3 run attribute @s minecraft:armor_toughness modifier add fallendream:ec_tou 1.5 add_value
execute if score #ec_n zx.meta matches 4 run attribute @s minecraft:armor_toughness modifier add fallendream:ec_tou 2.0 add_value
execute if score #ec_n zx.meta matches 5 run attribute @s minecraft:armor_toughness modifier add fallendream:ec_tou 2.5 add_value
execute if score #ec_n zx.meta matches 6 run attribute @s minecraft:armor_toughness modifier add fallendream:ec_tou 3.0 add_value
scoreboard players operation @s zx.ec_t = #ec_n zx.meta
