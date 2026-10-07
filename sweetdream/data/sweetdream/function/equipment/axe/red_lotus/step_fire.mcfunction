# ============================================================
# sweetdream:equipment/axe/red_lotus/step_fire —— 打一段「流火」
# ------------------------------------------------------------
# 【谁调用它】red_lotus/step   【执行者】施法者本人   【位置】他所在处
# 【两步】
#   ① 从名单里摘掉一只带「流火」的生物 —— 就近优先(sort=nearest),
#      它就是这一段"消耗的那一层"。摘掉之后这一段不会重复点它。
#   ② 重算伤害(基础攻击力 ×1) -> 以自身为圆心打一圈(hit_fire: 自身 5 格内全部生物)。
# 【★ 伤害为什么每段重算 ★】zx:work rl 是全包共用的临时节点, 跨刻留着会被别的
#   施法者/其它技能覆盖(见 recalc 头注释)。每段当场算、当场用, 多人也不会串。
# ============================================================

# ① 摘一只(就近优先)
execute at @s as @e[tag=zx.rl_fire,distance=0..,sort=nearest,limit=1] run tag @s remove zx.rl_fire

# ② 算这一段的伤害 + 打出去
function sweetdream:equipment/axe/red_lotus/recalc
function sweetdream:equipment/axe/red_lotus/hit_fire
