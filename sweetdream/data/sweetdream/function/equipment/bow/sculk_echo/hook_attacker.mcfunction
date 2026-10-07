# ============================================================
# sweetdream:equipment/bow/sculk_echo/hook_attacker —— 附魔回调: 记下射手
# ------------------------------------------------------------
# 【谁调它】附魔 sweetdream:sculk_echo(「幽匿残响」)的 post_attack, affected = attacker
# 【执行者】射手(玩家)
# 【为什么这样就一定是这把弩射的】附魔只写在幽匿残响上, 命中判定交给原版。
# ============================================================

tag @e[tag=zx.se_pl] remove zx.se_pl
tag @s add zx.se_pl
