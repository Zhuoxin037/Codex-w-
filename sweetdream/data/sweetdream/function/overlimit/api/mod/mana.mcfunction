# ============================================================
# sweetdream:overlimit/api/mod/mana —— arg.mana x (1 + 超限耗蓝)
# ------------------------------------------------------------
# 【定点算法】NBT 的 double 不能直接相乘, 走计分板:
#   值 x1000 -> 整数(保住三位小数) -> x(100+百分比) / 100 -> x0.001 换回 double。
#   250.0 x1.30 -> 325.0 ✓   0.04 x1.25 -> 0.05 ✓
# 【出参】① 改 manacore:in arg.mana ② 抄一份到 zx:work olv.mana(给扣蓝那步用)
# ============================================================

scoreboard players set #ol_v zx.meta 0
execute store result score #ol_v zx.meta run data get storage manacore:in arg.mana 1000
scoreboard players set #ol_p zx.meta 100
scoreboard players operation #ol_p zx.meta += #ol_m zx.meta
scoreboard players operation #ol_v zx.meta *= #ol_p zx.meta
scoreboard players operation #ol_v zx.meta /= #100 zx.meta
execute store result storage manacore:in arg.mana double 0.001 run scoreboard players get #ol_v zx.meta
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
