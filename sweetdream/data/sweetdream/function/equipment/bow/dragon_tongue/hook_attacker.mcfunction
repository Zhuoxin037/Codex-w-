# ============================================================
# sweetdream:equipment/bow/dragon_tongue/hook_attacker —— 附魔回调: 记下射手
# ------------------------------------------------------------
# 【谁调它】附魔 sweetdream:dragon_tongue 的 post_attack, affected = attacker
#   —— 也就是"射箭的那个人"。钩子的两边各用一个标签交汇(zx.dt_pl / zx.dt_arr),
#   顺序反了也能对上。
# 【执行者】射手(玩家)
# ============================================================

tag @e[tag=zx.dt_pl,distance=0..] remove zx.dt_pl
tag @s add zx.dt_pl
