# ============================================================
# sweetdream:equipment/bow/ember_string/hook_arrow —— 附魔回调: 记下"造成伤害的那支箭"
# ------------------------------------------------------------
# 【谁调它】附魔 sweetdream:ember_string 的 post_attack, affected = damaging_entity。
# 【★ 近战门控 ★】damaging_entity 不是箭时这里不打标签 -> hook_victim 开头收工。
# 【诊断锚 #es_dbg0】箭回调被触发几次(debug/bow_probe 读它)。
# ============================================================

scoreboard players add #es_dbg0 zx.meta 1
tag @e[tag=zx.es_arr,distance=0..] remove zx.es_arr
execute if entity @s[type=#sweetdream:cc_arrow] run tag @s add zx.es_arr
