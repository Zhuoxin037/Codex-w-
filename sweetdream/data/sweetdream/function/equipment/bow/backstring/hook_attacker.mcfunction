# ============================================================
# sweetdream:equipment/bow/backstring/hook_attacker —— 附魔回调: 记下射手
# ------------------------------------------------------------
# 【谁调它】附魔 sweetdream:backstring 的 post_attack, affected = attacker
#   —— 也就是"射箭的那个人"。钩子的两边各用一个标签交汇(zx.bs_pl / zx.bs_arr),
#   顺序反了也能对上。
# 【执行者】射手(玩家)
# ============================================================

tag @e[tag=zx.bs_pl,distance=0..] remove zx.bs_pl
tag @s add zx.bs_pl
