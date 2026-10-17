# ============================================================
# sweetdream:equipment/bow/dark_sun/hook_attacker —— 附魔回调: 记下射手
# ------------------------------------------------------------
# 【谁调它】附魔 sweetdream:dark_sun 的 post_attack, affected = attacker。
# 【执行者】射手(玩家)
# ============================================================

tag @e[tag=zx.ds_pl,distance=0..] remove zx.ds_pl
tag @s add zx.ds_pl
