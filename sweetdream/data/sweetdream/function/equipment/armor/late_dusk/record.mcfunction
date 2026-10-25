# ============================================================
# sweetdream:equipment/armor/late_dusk/record —— 记录窗口内累加这一次伤害
# ------------------------------------------------------------
# 【谁调用它】internal/damage/one（受击侧, @s = 挨打的生物）
# 【★ 必须在 deal **之前** ★】此时 a.num 已经是最终伤害（升痕/易伤/减伤都算完了）,
#   记到的是"实际要打出去多少"; 放到 deal 之后读, 数值可能已被后续段改过。
# 【★ 记的是全部来源 ★】文案是"其受到的伤害", 不区分谁打的 —— 只按"窗口开着没有"判。
# 【×1000 定点】a.num 是 double, `data get … 1000` 取千分位存进计分项。
# ============================================================

# ① 没在记录窗口里 ⇒ 收工
execute unless entity @s[scores={zx.ld_rt=1..}] run return 0

# ② 累加（千分定点）
scoreboard players set #ld_ad zx.meta 0
execute store result score #ld_ad zx.meta run data get storage zx:work a.num 1000
scoreboard players operation @s zx.ld_rec += #ld_ad zx.meta
