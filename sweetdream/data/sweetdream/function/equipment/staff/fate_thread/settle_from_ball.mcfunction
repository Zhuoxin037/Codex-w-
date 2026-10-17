# ============================================================
# sweetdream:equipment/staff/fate_thread/settle_from_ball —— 从法球换回发射者身份
# ------------------------------------------------------------
# 【谁调用它】ball_hit ③   【执行者】法球   【位置】命中点
# 【为什么需要】settle 要算"自身最大魔力值 ×0.05"、还要把击杀算在玩家头上,
#   所以必须换回**发射者**身份。球这里只带 u0..u3, 用 lib/find_by 反查。
# 【★ lib/find_by 是宏函数 ★】必须 with storage 传参, 不能裸调。
# ============================================================

data modify storage zx:work fb.u0 set from entity @s data.u0
data modify storage zx:work fb.u1 set from entity @s data.u1
data modify storage zx:work fb.u2 set from entity @s data.u2
data modify storage zx:work fb.u3 set from entity @s data.u3
function sweetdream:lib/find_by with storage zx:work fb

# 反查不到人 = 发射者已离线 -> 整段跳过(不报错)
execute as @a[tag=zx.mc_by,limit=1] run function sweetdream:equipment/staff/fate_thread/settle
tag @a remove zx.mc_by
