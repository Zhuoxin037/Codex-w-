# ============================================================
# fallendream:equipment/armor/overflow/second —— 「溢流」常驻生命上限 +4
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】魔力 +80（armor_mana 登记），最大生命值 +4。
#   被过量治疗后 50% 溢出量转临时生命（hook 在 lib/heal 出口 → overflow/hook_heal）。
# 【★ 生命上限用 add_value 4 ★】不是百分比（"+20%" 那种才用 add_multiplied_total）。
# ============================================================

execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["overflow"]}] run function fallendream:equipment/armor/overflow/off
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["overflow"]}] run return 0

# 换档先撤旧 modifier 再按档各写一条字面量 add（同 id 直接 add 会失败）
scoreboard players add @s zx.ov_hp 0
scoreboard players set #ovf_want zx.meta 4
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["overflow"],ol:"overflow"}] run scoreboard players set #ovf_want zx.meta 8
execute unless score @s zx.ov_hp = #ovf_want zx.meta run function fallendream:equipment/armor/overflow/sync_hp


# ---- 超限：非攻击造成的吸收减少（到期/别的技能清掉）也要回 1% 魔力 ----
#   攻击那一路在 overflow/hurt 里已经同步过 zx.ov_last，这里不会重复给。
execute unless score #ovf_want zx.meta matches 8 run return 0
scoreboard players add @s zx.ov_last 0
scoreboard players set #ovf_real zx.meta 0
execute store result score #ovf_real zx.meta run data get entity @s AbsorptionAmount 100
execute if score #ovf_real zx.meta < @s zx.ov_last run function fallendream:equipment/armor/overflow/loss_reward
scoreboard players operation @s zx.ov_last = #ovf_real zx.meta
