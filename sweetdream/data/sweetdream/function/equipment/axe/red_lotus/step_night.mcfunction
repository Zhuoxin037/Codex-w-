# ============================================================
# sweetdream:equipment/axe/red_lotus/step_night —— 打一段「夜火」
# ------------------------------------------------------------
# 【谁调用它】red_lotus/step   【执行者】施法者本人   【位置】他所在处
# 【两步】同 step_fire, 差别只在通道与半径:
#   ① 从名单里摘掉一只带「夜火」的生物(就近优先);
#   ② 重算伤害(基础攻击力 ×3) -> hit_night: 自身 6 格内全部生物。
# ============================================================

# ① 摘一只(就近优先)
execute at @s as @e[tag=zx.rl_night,distance=0..,sort=nearest,limit=1] run tag @s remove zx.rl_night

# ② 算这一段的伤害 + 打出去
function sweetdream:equipment/axe/red_lotus/recalc
function sweetdream:equipment/axe/red_lotus/hit_night
