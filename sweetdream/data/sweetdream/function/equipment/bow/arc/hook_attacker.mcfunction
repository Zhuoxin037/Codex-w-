# ============================================================
# sweetdream:equipment/bow/arc/hook_attacker —— 附魔回调: 记下射手
# ------------------------------------------------------------
# 【谁调它】附魔 sweetdream:arc(「电弧」)的 post_attack, affected = attacker
#   —— 也就是"射箭的那个人"。
# 【为什么需要它】「电弧」放电的伤害口径是"**自身**基础攻击力 ×2 + 当前魔力 ×0.03",
#   这个"自身" = 射手。放电发生在**受害者那一侧**(hook_victim), 那里拿不到射手,
#   所以先用一个标签把射手标出来, hook_victim 再按它切身份去查面板。
# 【执行者】射手(玩家)
# 【顺序】arc.json 里排在 damaging_entity 之后、victim 之前, 所以 hook_victim
#   跑到时射手已经标好了。
# ============================================================

tag @e[tag=zx.arc_pl] remove zx.arc_pl
tag @s add zx.arc_pl
