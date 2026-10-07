# ============================================================
# sweetdream:equipment/bow/rainbow/snap_prep —— 决定"这一发"用哪份快照
# ------------------------------------------------------------
# 【宏参数】zx:work rb {uuid, arrow}
# 【产出】zx:work rb.snap {ok,u0..u3}
#   ① 先铺"射手最近一发" ② 若这一箭自带快照就覆盖
# ============================================================

data modify storage zx:work rb.snap set value {ok:0b,u0:0,u1:0,u2:0,u3:0}
$data modify storage zx:work rb.snap.ok set from storage zx:data rb."$(uuid)".ok
$data modify storage zx:work rb.snap.u0 set from storage zx:data rb."$(uuid)".u0
$data modify storage zx:work rb.snap.u1 set from storage zx:data rb."$(uuid)".u1
$data modify storage zx:work rb.snap.u2 set from storage zx:data rb."$(uuid)".u2
$data modify storage zx:work rb.snap.u3 set from storage zx:data rb."$(uuid)".u3

$execute if entity $(arrow) if data entity $(arrow) data.zx.rb{ok:1b} run data modify storage zx:work rb.snap set from entity $(arrow) data.zx.rb
