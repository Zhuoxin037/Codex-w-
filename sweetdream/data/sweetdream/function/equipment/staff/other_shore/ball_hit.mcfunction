# ============================================================
# sweetdream:equipment/staff/other_shore/ball_hit —— 彼岸普攻的命中回调
# ------------------------------------------------------------
# 【谁调用它】projectile/ball/hit 第 ⑥ 步(球的 data.hit)
# 【执行者】法球本身   【位置】命中点   【入参】entity @s data = 球的数据(含 u0..u3)
# 【技能原文】"每次普攻命中后若其未附有「渊海」和「噬心」，则使其附加「渊海」。
#   若其只附有其中一种，则有 25% 的概率使其附加另一种。若其同时附有「渊海」和
#   「噬心」，则额外造成一次相当于自身最大魔力值 ×0.03 的真实伤害。附加效果对
#   同一个生物 8 秒内最多触发一次。"
# 【★ 顺序 ★】先逐只过 8 秒节流(p_gate), 只有通过的才进入分类与结算;
#   节流 **不影响** 这一发普攻本身的伤害(球已经打出去了)。
# 【★ 为什么必须换回发射者身份 ★】双状态那一段要算"自身最大魔力值 ×0.03" ——
#   要读玩家面板; 法球身上只有 u0..u3, 所以走 lib/find_by 反查(同命缕/醒梦钟)。
# ============================================================

# ① 逐只过 8 秒节流(记在**被命中的生物**身上 -> 每只各自计时)
tag @e[tag=zx.os_pass,distance=0..] remove zx.os_pass
execute as @e[tag=zx.ball_hit,distance=0..] run function sweetdream:equipment/staff/other_shore/p_gate

# ② 一只都没通过 -> 这一发只算普攻伤害, 收工
execute unless entity @e[tag=zx.os_pass,distance=0..] run return 0

# ③ 反查发射者(球的 data.u0..u3)
data modify storage zx:work fb.u0 set from entity @s data.u0
data modify storage zx:work fb.u1 set from entity @s data.u1
data modify storage zx:work fb.u2 set from entity @s data.u2
data modify storage zx:work fb.u3 set from entity @s data.u3
function sweetdream:lib/find_by with storage zx:work fb

# ④ 换回发射者身份, 位置搬到第一只通过者身上(后面 api/damage 用 at @s)
execute as @a[tag=zx.mc_by,limit=1] at @e[tag=zx.os_pass,distance=0..,limit=1] run function sweetdream:equipment/staff/other_shore/hit_go
tag @a remove zx.mc_by
