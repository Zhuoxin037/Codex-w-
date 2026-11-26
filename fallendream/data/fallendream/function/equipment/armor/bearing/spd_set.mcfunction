# ============================================================
# fallendream:equipment/armor/bearing/spd_set —— 换"移速"档（#br_s = 目标档）
# ------------------------------------------------------------
# 【★ 字面量禁区 ★】modifier 的数值只能是字面量 ⇒ 6% / 8% 各写一条。
# 【档位】#br_s = 0 不挂 / 1 基础 6% / 2 超限 8%
# 【★ 账本 zx.br_spd 记的是档位, 不是 0/1 ★】超限档要把 6% 换成 8%,
#   只记"挂没挂"的话换档时会以为不用动。
# ============================================================

execute if score @s zx.br_spd matches 1.. run attribute @s minecraft:movement_speed modifier remove fallendream:br_spd
scoreboard players set @s zx.br_spd 0
execute if score #br_s zx.meta matches 1 run attribute @s minecraft:movement_speed modifier add fallendream:br_spd 0.06 add_multiplied_total
execute if score #br_s zx.meta matches 2 run attribute @s minecraft:movement_speed modifier add fallendream:br_spd 0.08 add_multiplied_total
scoreboard players operation @s zx.br_spd = #br_s zx.meta
