# ============================================================
# sweetdream:equipment/bow/sculk_echo/snap_prep —— 决定"这一发"用哪份快照
# ------------------------------------------------------------
# 【宏参数】zx:work se {uuid, arrow}
# 【产出】zx:work se.snap {ok,hit_dmg,path_dmg,cry,u0..u3}
#   ① 先铺"射手最近一发"(zx:data se."<uuid>") —— 兜底
#   ② 若这一箭自己带快照(data.zx.se)就整个覆盖 —— 逐箭优先
# ============================================================

data modify storage zx:work se.snap set value {ok:0b,hit_dmg:0.0,path_dmg:0.0,cry:0,u0:0,u1:0,u2:0,u3:0}
$data modify storage zx:work se.snap.hit_dmg set from storage zx:data se."$(uuid)".hit_dmg
$data modify storage zx:work se.snap.path_dmg set from storage zx:data se."$(uuid)".path_dmg
$data modify storage zx:work se.snap.cry set from storage zx:data se."$(uuid)".cry
$data modify storage zx:work se.snap.u0 set from storage zx:data se."$(uuid)".u0
$data modify storage zx:work se.snap.u1 set from storage zx:data se."$(uuid)".u1
$data modify storage zx:work se.snap.u2 set from storage zx:data se."$(uuid)".u2
$data modify storage zx:work se.snap.u3 set from storage zx:data se."$(uuid)".u3

$execute if entity $(arrow) if data entity $(arrow) data.zx.se{ok:1b} run data modify storage zx:work se.snap set from entity $(arrow) data.zx.se
