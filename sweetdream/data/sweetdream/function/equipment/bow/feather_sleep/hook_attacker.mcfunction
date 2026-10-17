# ============================================================
# sweetdream:equipment/bow/feather_sleep/hook_attacker —— 附魔回调: 记下射手
# ------------------------------------------------------------
# 【谁调它】附魔 sweetdream:feather_sleep 的 post_attack, affected = attacker。
# 【为什么这样就一定是"眠羽射的箭"】这个附魔只写在眠羽这把弩上, 原版 post_attack
#   会认"射出这支箭的那把武器" -> 命中判定交给原版。
# 【执行者】射手(玩家)
# ============================================================

tag @e[tag=zx.fs_pl,distance=0..] remove zx.fs_pl
tag @s add zx.fs_pl
