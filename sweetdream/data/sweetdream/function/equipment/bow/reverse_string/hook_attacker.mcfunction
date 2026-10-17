# ============================================================
# sweetdream:equipment/bow/reverse_string/hook_attacker —— 附魔回调: 记下射手
# ------------------------------------------------------------
# 【谁调它】附魔 sweetdream:reverse_string 的 post_attack, affected = attacker。
# 【执行者】射手(玩家)
# ============================================================

tag @e[tag=zx.rs_pl,distance=0..] remove zx.rs_pl
tag @s add zx.rs_pl
