# ============================================================
# sweetdream:equipment/staff/five_curses/ball_hit —— 五世恶咒普攻的命中回调
# ------------------------------------------------------------
# 【谁调用它】projectile/ball/hit 第 ⑥ 步: `function $(hit) with entity @s data`
#   (@s = 法球本体, 位置 = 命中点; 宏参数 = 球的全部 data)
#   ⚠️ 此刻 zx.ball_hit 标签还没摘(ball/hit 第 ⑦ 步才清) —— 命中的生物
#   就用 @e[tag=zx.ball_hit] 圈出来。
# 【本回调只做一件事: 叠世咒】伤害由 ball/hit 第 ④ 步按 data.dmg 打过了,
#   这里**不再重复结算**(堕梦是因为要"普通伤害改真伤"才把 dmg 设 0 另存 fdmg)。
# 【为什么要把 u0..u3 抄进 storage】curse_step 要把"谁下的咒"记到目标身上,
#   而法球的 uuid 在**球的 data** 里 —— 先搬进 storage 才能跨函数带着走。
# ============================================================

# ⓪ 把施法者的 uuid 四段从球上搬到 storage(给 curse_step 用)
data modify storage zx:work fcv.u0 set from entity @s data.u0
data modify storage zx:work fcv.u1 set from entity @s data.u1
data modify storage zx:work fcv.u2 set from entity @s data.u2
data modify storage zx:work fcv.u3 set from entity @s data.u3

# ① 命中的每只生物: 推进一世
execute as @e[tag=zx.ball_hit] at @s run function sweetdream:equipment/staff/five_curses/curse_step
