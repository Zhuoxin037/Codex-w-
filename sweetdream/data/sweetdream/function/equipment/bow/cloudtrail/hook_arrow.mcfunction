# ============================================================
# sweetdream:equipment/bow/cloudtrail/hook_arrow —— 附魔回调: 记下"造成伤害的那支箭"
# ------------------------------------------------------------
# 【谁调它】附魔 sweetdream:cloudtrail 的 post_attack, affected = damaging_entity。
# 【★ 两层门控 ★】
#   ① 近战门控: 不是箭就不打标签 -> hook_victim 开头收工;
#   ② 已付钱门控: **不在这一层做**(坑 141) —— 改去 hook_victim 里读**射手身上**
#      的 zx.ct_paid。射击那一刻箭可能还没进世界, 箭上的 zx.ct_ok 靠不住。
#      (zx.ct_ok 现在只用于"落地检测"，不再是"付过钱"的判据。)
# 【★ 顺手把"落地驱动标签"摘掉 ★】这一箭打中了生物 = 它**没有**落空 ——
#   不能让 core/tick 的落地检测把它当成"未射中"而在原地建一个领域。
#   (箭命中生物后通常会被移除, 但先把标记摘干净更保险。)
# ============================================================

scoreboard players add #ct_dbg0 zx.meta 1
tag @e[tag=zx.ct_arr,distance=0..] remove zx.ct_arr
execute if entity @s[type=#sweetdream:cc_arrow] run tag @s add zx.ct_arr
execute if entity @s[type=#sweetdream:cc_arrow] run tag @s remove zx.ct_live
