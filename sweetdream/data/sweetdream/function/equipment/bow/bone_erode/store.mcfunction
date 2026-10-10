# ============================================================
# sweetdream:equipment/bow/bone_erode/store —— 把"这一发"挂在射手名下(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work be {uuid,dmg,ol,u0,u1,u2,u3}
# 【执行者】射手(玩家)
# 【存哪】zx:data be."<uuid>" —— 一个玩家一份, 多人同时射也互不影响。
#   命中时若认不到箭, 退回来读这份兜底(见 fire)。
#   ★ ol = 这一发是不是超限版(2026-10-10 加), 跟着一起存。
# ============================================================

$data modify storage zx:data be."$(uuid)" set value {dmg:0.0,ol:0b,u0:0,u1:0,u2:0,u3:0}
$data modify storage zx:data be."$(uuid)".dmg set value $(dmg)
$data modify storage zx:data be."$(uuid)".ol set value $(ol)
$data modify storage zx:data be."$(uuid)".u0 set value $(u0)
$data modify storage zx:data be."$(uuid)".u1 set value $(u1)
$data modify storage zx:data be."$(uuid)".u2 set value $(u2)
$data modify storage zx:data be."$(uuid)".u3 set value $(u3)
