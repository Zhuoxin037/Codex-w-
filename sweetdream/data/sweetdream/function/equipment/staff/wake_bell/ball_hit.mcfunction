# ============================================================
# sweetdream:equipment/staff/wake_bell/ball_hit —— 醒梦钟普攻的命中回调
# ------------------------------------------------------------
# 【谁调用它】projectile/ball/hit 第 ⑥ 步(球的 data.hit)
# 【执行者】法球本身   【位置】命中点   【入参】entity @s data = 球的数据(含 u0..u3)
# 【技能原文】"每次普攻命中后若其附有「白昼梦」，则额外造成一次相当于自身最大魔力值
#   ×0.02 的伤害。"
# 【★ 这一发打中了谁 ★】ball/hit 第 ① 步已经把"球周围那个盒子里"的全部可伤害生物
#   挂上了 zx.ball_hit, 要到第 ⑦ 步才摘 —— 所以本文件能直接读这批人。
# 【★ 追加伤害必须以发射者身份投递 ★】
#   · 算伤要玩家的面板(最大魔力值) -> 需要他的 uuid;
#   · 归属(击杀算谁的)也看执行者是不是玩家。
#   球这里 @s 是法球, 只能用 data.u0..u3 反查发射者(lib/find_by), 再换身份。
# ============================================================

# ① 这一发命中的那批里, 只要有一只带「白昼梦」就成立
scoreboard players set #wb_dr zx.meta 0
execute as @e[tag=zx.ball_hit,distance=0..] if entity @s[tag=zx.status.dream] run scoreboard players set #wb_dr zx.meta 1
execute if score #wb_dr zx.meta matches 0 run return 0

# ② 用球的归属 UUID 反查发射者(打 zx.mc_by 标签)
data modify storage zx:work fb.u0 set from entity @s data.u0
data modify storage zx:work fb.u1 set from entity @s data.u1
data modify storage zx:work fb.u2 set from entity @s data.u2
data modify storage zx:work fb.u3 set from entity @s data.u3
function sweetdream:lib/find_by with storage zx:work fb

# ③ 换成发射者身份结算(反查不到人 = 发射者离线, 自然跳过)
execute as @a[tag=zx.mc_by,limit=1] run function sweetdream:equipment/staff/wake_bell/ball_extra
tag @a remove zx.mc_by
