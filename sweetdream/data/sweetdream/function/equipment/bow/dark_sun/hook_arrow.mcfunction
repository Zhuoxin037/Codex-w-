# ============================================================
# sweetdream:equipment/bow/dark_sun/hook_arrow —— 附魔回调: 记下"造成伤害的那支箭"
# ------------------------------------------------------------
# 【谁调它】附魔 sweetdream:dark_sun 的 post_attack, affected = damaging_entity。
# 【★ 近战门控 ★】damaging_entity 不是箭时这里不打标签 -> hook_victim 开头收工。
# 【诊断锚 #ds_dbg0】箭回调被触发几次(debug/bow_probe 读它)。
# ============================================================

scoreboard players add #ds_dbg0 zx.meta 1
tag @e[tag=zx.ds_arr,distance=0..] remove zx.ds_arr
execute if entity @s[type=#sweetdream:cc_arrow] run tag @s add zx.ds_arr
