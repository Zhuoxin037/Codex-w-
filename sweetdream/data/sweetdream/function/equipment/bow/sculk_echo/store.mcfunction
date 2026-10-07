# ============================================================
# sweetdream:equipment/bow/sculk_echo/store —— 把"这一发"挂在射手名下(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work se {uuid,hit_dmg,path_dmg,cry,u0..u3}
# 【执行者】射手(玩家)
# 【存哪】zx:data se."<uuid>" —— 一个玩家一份, 命中时认不到箭就退回来读它。
# ============================================================

$data modify storage zx:data se."$(uuid)" set value {hit_dmg:0.0,path_dmg:0.0,cry:0,u0:0,u1:0,u2:0,u3:0}
$data modify storage zx:data se."$(uuid)".hit_dmg set value $(hit_dmg)
$data modify storage zx:data se."$(uuid)".path_dmg set value $(path_dmg)
$data modify storage zx:data se."$(uuid)".cry set value $(cry)
$data modify storage zx:data se."$(uuid)".u0 set value $(u0)
$data modify storage zx:data se."$(uuid)".u1 set value $(u1)
$data modify storage zx:data se."$(uuid)".u2 set value $(u2)
$data modify storage zx:data se."$(uuid)".u3 set value $(u3)
