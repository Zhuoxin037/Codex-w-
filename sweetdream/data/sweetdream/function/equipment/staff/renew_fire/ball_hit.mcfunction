# ============================================================
# sweetdream:equipment/staff/renew_fire/ball_hit —— 续火普攻的命中回调
# ------------------------------------------------------------
# 【谁调用它】projectile/ball/hit 第 ⑥ 步(球的 data.hit)
# 【执行者】法球本身   【位置】命中点   【入参】entity @s data = 球的数据(含 u0..u3)
# 【技能原文】"每次普攻**命中后累计一次**，每累计 3 次则恢复自身 1 点生命值。"
# 【★ 一次普攻只累计 1 次 ★】哪怕这一发打中了三只, 也只算"一次普攻命中" ——
#   所以本文件只判"有没有打到生物", 不按命中数累加。
# 【★ 计数必须记在发射者(玩家)身上 ★】球这里 @s 是法球, 用 data.u0..u3 反查
#   (lib/find_by), 再换身份调 reward。
# ============================================================

# ① 这一发打到生物了吗? 一个都没打到 -> 不累计(打空气/打方块不算命中)
execute unless entity @e[tag=zx.ball_hit,distance=0..,limit=1] run return 0

# ② 用球的归属 UUID 反查发射者(打 zx.mc_by 标签)
data modify storage zx:work fb.u0 set from entity @s data.u0
data modify storage zx:work fb.u1 set from entity @s data.u1
data modify storage zx:work fb.u2 set from entity @s data.u2
data modify storage zx:work fb.u3 set from entity @s data.u3
function sweetdream:lib/find_by with storage zx:work fb

# ③ 换成发射者身份累计(反查不到人 = 发射者离线, 自然跳过)
execute as @a[tag=zx.mc_by,limit=1] run function sweetdream:equipment/staff/renew_fire/reward
tag @a remove zx.mc_by
