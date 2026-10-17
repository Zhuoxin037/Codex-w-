# ============================================================
# sweetdream:equipment/staff/long_night/prepare —— 反查施法者, 换身份后跑"消耗那一步"
# ------------------------------------------------------------
# 【谁调用它】field_tick ④   【执行者】夜原 marker   【位置】夜原中心
# 【为什么单独一层】要把"执行身份"换成施法者, 但"位置"必须留在夜原中心:
#     `execute at @s as @a[tag=zx.mc_by,limit=1]`
#   · at @s   -> 把坐标/维度定在夜原中心(施法者可能已经走远, 不能拿他的坐标当圆心)
#   · as <他> -> 之后 @s 是施法者本人 —— 消耗时「余烬」才认得出"消耗者身上的装备"
# 【★ 为什么不能只传 by ★】lib/on_consume 里余烬只认 @s(原执行者), by 只有
#   永恒/回潮扣/烛跬 用。所以身份必须真的换过去。
# ============================================================

# ① 用 marker 上存的 UUID 四个整数反查施法者(打 zx.mc_by 标签)
data modify storage zx:work fb.u0 set from entity @s data.zx.u[0]
data modify storage zx:work fb.u1 set from entity @s data.zx.u[1]
data modify storage zx:work fb.u2 set from entity @s data.zx.u[2]
data modify storage zx:work fb.u3 set from entity @s data.zx.u[3]
function sweetdream:lib/find_by with storage zx:work fb

# ② 位置留在夜原中心, 身份换成施法者(反查不到人 -> @a[...] 选 0 人, 这一步自然跳过)
execute at @s as @a[tag=zx.mc_by,limit=1] run function sweetdream:equipment/staff/long_night/fire_one
tag @a remove zx.mc_by
