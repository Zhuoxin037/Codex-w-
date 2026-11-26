# ============================================================
# fallendream:equipment/armor/empty_camp/attr_arm —— 换护甲档（#ec_n = 层数 0..6）
# ------------------------------------------------------------
# 【★ 字面量禁区 ★】modifier 数值只能是字面量 ⇒ 1..6 六条分支各写一条。
# ============================================================

execute if score @s zx.ec_a matches 1.. run attribute @s minecraft:armor modifier remove fallendream:ec_arm
scoreboard players set @s zx.ec_a 0
execute if score #ec_n zx.meta matches 1 run attribute @s minecraft:armor modifier add fallendream:ec_arm 1 add_value
execute if score #ec_n zx.meta matches 2 run attribute @s minecraft:armor modifier add fallendream:ec_arm 2 add_value
execute if score #ec_n zx.meta matches 3 run attribute @s minecraft:armor modifier add fallendream:ec_arm 3 add_value
execute if score #ec_n zx.meta matches 4 run attribute @s minecraft:armor modifier add fallendream:ec_arm 4 add_value
execute if score #ec_n zx.meta matches 5 run attribute @s minecraft:armor modifier add fallendream:ec_arm 5 add_value
execute if score #ec_n zx.meta matches 6 run attribute @s minecraft:armor modifier add fallendream:ec_arm 6 add_value
scoreboard players operation @s zx.ec_a = #ec_n zx.meta
