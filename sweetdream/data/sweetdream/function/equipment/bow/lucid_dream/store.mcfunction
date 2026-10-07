# ============================================================
# sweetdream:equipment/bow/lucid_dream/store —— 挂在射手名下(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work ld {uuid,ok,combo,u0,u1,u2,u3}
# ============================================================

$data modify storage zx:data ld."$(uuid)" set value {ok:0b,combo:0,u0:0,u1:0,u2:0,u3:0}
$data modify storage zx:data ld."$(uuid)".ok set value $(ok)
$data modify storage zx:data ld."$(uuid)".combo set value $(combo)
$data modify storage zx:data ld."$(uuid)".u0 set value $(u0)
$data modify storage zx:data ld."$(uuid)".u1 set value $(u1)
$data modify storage zx:data ld."$(uuid)".u2 set value $(u2)
$data modify storage zx:data ld."$(uuid)".u3 set value $(u3)
