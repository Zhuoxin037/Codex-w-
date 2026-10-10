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
# 【★ R05 整数上界保护(2026-10-10)★】#ol_v 此刻是**×1000 定点**, 下一步要 ×#ol_p。
#   计分板是 **int32**, 中间值越过 2,147,483,647 会**回绕成负数** —— 不报错,
#   得到的却是一个天文数字或负值(表现就是"伤害突然变成几百亿/负数")。
#   这里补一道动态上限 = INT32_MAX ÷ #ol_p; 常态数值远不到那个量级, 一行都不受影响。
#   ★ 为什么带上 `matches 1..`: 除数如果是 0, 这条 operation **静默失败**(见坑 85 的
#     除零事故), 乘数是百分比加法的结果、被减到 0 以下是有可能的。
#   ★ 为什么不改成"先 ÷100 再 ×": 那会把 45.67 砍成 45, 让常态丢掉小数精度 ——
#     为防一个极端数值牺牲常态精度不划算(vuln_tag 那条注释里有同样的取舍)。
scoreboard players set #ol_cap zx.meta 2147483647
execute if score #ol_p zx.meta matches 1.. run scoreboard players operation #ol_cap zx.meta /= #ol_p zx.meta
execute if score #ol_p zx.meta matches 1.. if score #ol_v zx.meta > #ol_cap zx.meta run scoreboard players operation #ol_v zx.meta = #ol_cap zx.meta
scoreboard players operation #ol_v zx.meta *= #ol_p zx.meta
scoreboard players operation #ol_v zx.meta /= #100 zx.meta
execute store result storage manacore:in arg.mana double 0.001 run scoreboard players get #ol_v zx.meta
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
