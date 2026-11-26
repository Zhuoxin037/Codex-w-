# ============================================================
# fallendream:equipment/armor/cease_war/start —— 止战：职业攻击增益全部自然到期 -> 获得「余勇」
# ============================================================
execute unless score @s zx.job matches 2 run return 0
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["cease_war"]}] run return 0
scoreboard players add @s zx.s2_cw_cd 0
execute if score @s zx.s2_cw_cd > #now manacore.meta run return 0
scoreboard players operation @s zx.s2_cw_cd = #now manacore.meta
scoreboard players add @s zx.s2_cw_cd 320

# ---- 时段: 基础 8 秒(160) / 超限 16 秒(320) ----
scoreboard players set #cw_len zx.meta 160
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["cease_war"],ol:"cease_war"}] run scoreboard players set #cw_len zx.meta 320
scoreboard players operation @s zx.s2_cw_end = #now manacore.meta
scoreboard players operation @s zx.s2_cw_end += #cw_len zx.meta
tag @s add zx.s2_cw

# ---- 属性: 护甲 +6 / 击退抗性 +0.3（两档相同）----
attribute @s minecraft:armor modifier remove fallendream:cease_war
attribute @s minecraft:knockback_resistance modifier remove fallendream:cease_war
attribute @s minecraft:armor modifier add fallendream:cease_war 6 add_value
attribute @s minecraft:knockback_resistance modifier add fallendream:cease_war 0.3 add_value

# ---- 超限额外: 护甲韧性 +1 / 立即恢复 20% 生命值 ----
#   【文案】"✦ 余勇  立即恢复 20% 生命值。护甲值 +6，护甲韧性 +1，击退抗性 +0.3。"
scoreboard players set #cw_ol zx.meta 0
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["cease_war"],ol:"cease_war"}] run scoreboard players set #cw_ol zx.meta 1
execute if score #cw_ol zx.meta matches 1 run scoreboard players add @s zx.cw_t 0
execute if score #cw_ol zx.meta matches 1 if score @s zx.cw_t matches 1 run attribute @s minecraft:armor_toughness modifier remove fallendream:cease_war_t
execute if score #cw_ol zx.meta matches 1 if score @s zx.cw_t matches 1 run scoreboard players set @s zx.cw_t 0
execute if score #cw_ol zx.meta matches 1 run attribute @s minecraft:armor_toughness modifier add fallendream:cease_war_t 1 add_value
execute if score #cw_ol zx.meta matches 1 run scoreboard players set @s zx.cw_t 1

execute if score #cw_ol zx.meta matches 1 run function fallendream:lib/max_health_score
execute if score #cw_ol zx.meta matches 1 if score #max_hp zx.meta matches 1.. run scoreboard players operation #mp_src zx.meta = #max_hp zx.meta
execute if score #cw_ol zx.meta matches 1 if score #max_hp zx.meta matches 1.. run scoreboard players set #mp_mul zx.meta 200
execute if score #cw_ol zx.meta matches 1 if score #max_hp zx.meta matches 1.. run function fallendream:lib/math/mul_permille
execute if score #cw_ol zx.meta matches 1 if score #max_hp zx.meta matches 1.. run scoreboard players set #cw_k zx.meta 1000
execute if score #cw_ol zx.meta matches 1 if score #max_hp zx.meta matches 1.. run scoreboard players operation #mp_out zx.meta /= #cw_k zx.meta
execute if score #cw_ol zx.meta matches 1 if score #max_hp zx.meta matches 1.. run scoreboard players operation #heal_pt zx.meta = #mp_out zx.meta
execute if score #cw_ol zx.meta matches 1 if score #max_hp zx.meta matches 1.. run function fallendream:lib/heal

# ---- 转化态标记与加攻账本归零（新一次余勇从"普通形态"开始）----
scoreboard players set @s zx.s2_cw_x 0
scoreboard players set @s zx.cw_st 0
scoreboard players set @s zx.cw_b0 0
scoreboard players set @s zx.cw_badd 0
