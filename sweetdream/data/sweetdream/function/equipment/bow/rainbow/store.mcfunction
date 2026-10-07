# ============================================================
# sweetdream:equipment/bow/rainbow/store —— 把"这一发"挂在射手名下(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work rb {uuid,ok,u0,u1,u2,u3}
# 【执行者】射手(玩家)
# ============================================================

$data modify storage zx:data rb."$(uuid)" set value {ok:0b,u0:0,u1:0,u2:0,u3:0}
$data modify storage zx:data rb."$(uuid)".ok set value $(ok)
$data modify storage zx:data rb."$(uuid)".u0 set value $(u0)
$data modify storage zx:data rb."$(uuid)".u1 set value $(u1)
$data modify storage zx:data rb."$(uuid)".u2 set value $(u2)
$data modify storage zx:data rb."$(uuid)".u3 set value $(u3)
