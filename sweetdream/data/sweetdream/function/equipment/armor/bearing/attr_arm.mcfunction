# ============================================================
# sweetdream:equipment/armor/bearing/attr_arm —— 换"护甲值"档（#br_a = 目标值）
# ------------------------------------------------------------
# 【★ 字面量禁区 ★】modifier 的数值只能是字面量 ⇒ 0/2/4/6 四档各写一条。
#   层数上限 3（最多 +6 护甲），改成别的上限时这四个分支必须一起改。
# ============================================================

execute if score @s zx.br_a matches 1.. run attribute @s minecraft:armor modifier remove sweetdream:br_arm
scoreboard players set @s zx.br_a 0
execute if score #br_a zx.meta matches 2 run attribute @s minecraft:armor modifier add sweetdream:br_arm 2 add_value
execute if score #br_a zx.meta matches 4 run attribute @s minecraft:armor modifier add sweetdream:br_arm 4 add_value
execute if score #br_a zx.meta matches 6 run attribute @s minecraft:armor modifier add sweetdream:br_arm 6 add_value
scoreboard players operation @s zx.br_a = #br_a zx.meta
