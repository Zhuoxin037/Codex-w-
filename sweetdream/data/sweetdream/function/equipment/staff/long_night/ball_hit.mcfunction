# ============================================================
# sweetdream:equipment/staff/long_night/ball_hit —— 长夜普攻的命中回调
# ------------------------------------------------------------
# 【谁调用它】projectile/ball/hit 第 ⑥ 步(球的 data.hit)
# 【执行者】法球本身   【位置】命中点   【入参】entity @s data = 球的数据(含 u0..u3)
# 【技能原文】"每次普攻命中了附有「夜火」的生物后，为自身恢复 30 点魔力值
#   （2 秒内最多一次）。"
# 【★ 这一发打中了谁 ★】ball/hit 第 ① 步已经把"球周围那个盒子里"的全部可伤害生物
#   挂上了 zx.ball_hit, 而且要到第 ⑦ 步才摘 —— 所以本文件能直接读这批人。
# 【★ 回魔必须"以发射者身份"做 ★】回魔 API 要玩家自己的 uuid;
#   球这里 @s 是法球, 只能用 data.u0..u3 反查发射者(lib/find_by), 再换身份。
# ============================================================

# ① 这一发命中的那批里, 只要有一只带「夜火」就成立
scoreboard players set #ln_ye zx.meta 0
execute as @e[tag=zx.ball_hit,distance=0..] if entity @s[tag=zx.status.yehuo] run scoreboard players set #ln_ye zx.meta 1
execute if score #ln_ye zx.meta matches 0 run return 0

# ② 用球的归属 UUID 反查发射者(打 zx.mc_by 标签)
data modify storage zx:work fb.u0 set from entity @s data.u0
data modify storage zx:work fb.u1 set from entity @s data.u1
data modify storage zx:work fb.u2 set from entity @s data.u2
data modify storage zx:work fb.u3 set from entity @s data.u3
function sweetdream:lib/find_by with storage zx:work fb

# ③ 换成发射者身份回魔(2 秒节流也记在他身上) —— 反查不到人(离线)就自然跳过
execute as @a[tag=zx.mc_by,limit=1] run function sweetdream:equipment/staff/long_night/mana_back
tag @a remove zx.mc_by
