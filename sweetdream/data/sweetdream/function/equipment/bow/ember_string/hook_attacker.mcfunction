# ============================================================
# sweetdream:equipment/bow/ember_string/hook_attacker —— 附魔回调: 记下射手
# ------------------------------------------------------------
# 【谁调它】附魔 sweetdream:ember_string 的 post_attack, affected = attacker。
# 【执行者】射手(玩家)
# ============================================================

tag @e[tag=zx.es_pl,distance=0..] remove zx.es_pl
tag @s add zx.es_pl
