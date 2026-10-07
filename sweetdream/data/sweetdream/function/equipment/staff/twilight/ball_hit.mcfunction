# ============================================================
# sweetdream:equipment/staff/twilight/ball_hit —— 暮光普攻的命中回调
# ------------------------------------------------------------
# 【谁调用它】projectile/ball/hit 第 ⑥ 步(`function $(hit) with entity @s data`)
#   (@s = 法球本体, 位置 = 命中点)
#   ⚠️ 此刻 zx.ball_hit 标签还没摘(ball/hit 第 ⑦ 步才清)。
# 【技能原文(lore 逐字)】每次普攻命中后有 20% 的概率使其附加「噬心」效果。
#   若成功附加则额外对其造成一次伤害。
# 【20% 怎么判】谓词 sweetdream:chance_20(minecraft:random_chance, chance:0.2),
#   和狄俄尼索斯头盔同一套。
# 【"额外造成一次伤害"的数值】文案没写别的口径 -> 就是这一发的伤害(球的 data.dmg)。
# ============================================================

execute if predicate sweetdream:chance_20 run function sweetdream:equipment/staff/twilight/tw_proc
