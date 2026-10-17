# ============================================================
# sweetdream:equipment/bow/feather_sleep/hook_arrow —— 附魔回调: 记下"造成伤害的那支箭"
# ------------------------------------------------------------
# 【谁调它】附魔 sweetdream:feather_sleep 的 post_attack, affected = damaging_entity。
# 【★ 近战门控 ★】damaging_entity 不是箭时这里不打标签 -> hook_victim 开头那句
#   "必须有 zx.fs_arr" 不成立 -> 拿弩近战敲人直接收工(2026-10-05 同族事故)。
# 【诊断锚 #fs_dbg0】箭回调被触发几次(debug/bow_probe 读它)。
# ============================================================

scoreboard players add #fs_dbg0 zx.meta 1
tag @e[tag=zx.fs_arr,distance=0..] remove zx.fs_arr
execute if entity @s[type=#sweetdream:cc_arrow] run tag @s add zx.fs_arr
