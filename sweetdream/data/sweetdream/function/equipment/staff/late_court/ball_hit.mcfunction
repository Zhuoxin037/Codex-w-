# ============================================================
# sweetdream:equipment/staff/late_court/ball_hit —— 迟庭普攻的命中回调
# ------------------------------------------------------------
# 【谁调用它】projectile/ball/hit 第 ⑥ 步(球的 data.hit)
# 【执行者】法球本身   【位置】命中点   【入参】entity @s data = 球的数据(含 u0..u3)
# 【技能原文】"每次普攻命中后，使其获得 2 秒缓慢Ⅱ。"
# 【★ 这一发打中了谁 ★】ball/hit 第 ① 步已经把"球周围那个盒子里"的全部可伤害生物
#   挂上了 zx.ball_hit, 而且要到第 ⑦ 步才摘 —— 所以本文件能直接读这批人。
# 【缓慢Ⅱ = amplifier 1】原版 effect 的等级 = amplifier + 1(见 iridescent/eff_1:
#   "5 秒缓慢 III(amplifier 2 = III 级)")。
# 【2 秒 = 40 刻, 但 effect give 的时长参数单位是**秒】** —— 写 2。
# 【不用"以发射者身份"】这条效果不需要玩家 uuid(只是给目标挂个原版效果),
#   所以直接在法球身份下 as 目标跑就行。
# ============================================================

execute as @e[tag=zx.ball_hit,distance=0..] run effect give @s minecraft:slowness 2 1 true
execute at @s run particle minecraft:dust{color:[0.85,0.62,0.30],scale:1.3} ~ ~0.6 ~ 0.6 0.6 0.6 0.02 12 normal
