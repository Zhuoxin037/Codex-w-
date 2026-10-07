# ============================================================
# sweetdream:equipment/axe/red_lotus/step —— 推一段(流火优先, 打完才轮到夜火)
# ------------------------------------------------------------
# 【谁调用它】cast(第 1 段) / tick_step(之后每 0.35 秒一段)
# 【执行者】施法者本人   【位置】他所在处
# 【一段 = 什么】从名单里摘掉一只带标签的生物, 按它的标签种类打一次范围伤害:
#     有「流火」名单 -> step_fire(自身 5 格内, 基础攻击力 ×1)
#     流火摘完了但还有「夜火」-> step_night(自身 6 格内, 基础攻击力 ×3)
#   ★ 两种名单都空 = 提前打完(比如中途有生物死了/走远了), 什么都不做。
# 【为什么不用 return】这里是普通函数, 两种情况的判定互斥且都是 `execute if/unless`,
#   没有需要"中断后续"的东西 —— 写 return 反而多一层控制流风险。
# ============================================================

# 还有「流火」-> 打一段流火
execute if entity @e[tag=zx.rl_fire,distance=0..] run function sweetdream:equipment/axe/red_lotus/step_fire

# 「流火」摘完了但还有「夜火」-> 打一段夜火
execute unless entity @e[tag=zx.rl_fire,distance=0..] if entity @e[tag=zx.rl_night,distance=0..] run function sweetdream:equipment/axe/red_lotus/step_night
