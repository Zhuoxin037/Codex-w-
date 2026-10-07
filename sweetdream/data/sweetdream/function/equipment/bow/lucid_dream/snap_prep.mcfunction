# ============================================================
# sweetdream:equipment/bow/lucid_dream/snap_prep —— 决定用哪份快照
# ============================================================

data modify storage zx:work ld.snap set value {ok:0b,combo:0,u0:0,u1:0,u2:0,u3:0}
$data modify storage zx:work ld.snap.ok set from storage zx:data ld."$(uuid)".ok
$data modify storage zx:work ld.snap.combo set from storage zx:data ld."$(uuid)".combo
$data modify storage zx:work ld.snap.u0 set from storage zx:data ld."$(uuid)".u0
$data modify storage zx:work ld.snap.u1 set from storage zx:data ld."$(uuid)".u1
$data modify storage zx:work ld.snap.u2 set from storage zx:data ld."$(uuid)".u2
$data modify storage zx:work ld.snap.u3 set from storage zx:data ld."$(uuid)".u3

$execute if entity $(arrow) if data entity $(arrow) data.zx.ld{ok:1b} run data modify storage zx:work ld.snap set from entity $(arrow) data.zx.ld
