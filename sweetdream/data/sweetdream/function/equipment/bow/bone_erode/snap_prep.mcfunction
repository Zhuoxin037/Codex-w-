# ============================================================
# sweetdream:equipment/bow/bone_erode/snap_prep —— 决定"这一发"用哪份快照
# ------------------------------------------------------------
# 【宏参数】zx:work be {uuid, arrow}
# 【产出】zx:work be.snap {ok,dmg,ol,u0..u3} —— fire 只认这一份
# 【★ 两步, 后覆盖前 ★】
#   ① 先铺"射手最近一发"(zx:data be."<uuid>") —— 兜底。
#   ② 若这一箭自己带快照(data.zx.be)就整个覆盖 —— 逐箭永远优先。
#   ★ ol 也一起合并(超限版才走真实伤害 + 噬心追击)。
# ============================================================

data modify storage zx:work be.snap set value {ok:0b,dmg:0.0,ol:0b,u0:0,u1:0,u2:0,u3:0}
$data modify storage zx:work be.snap.dmg set from storage zx:data be."$(uuid)".dmg
$data modify storage zx:work be.snap.ol set from storage zx:data be."$(uuid)".ol
$data modify storage zx:work be.snap.u0 set from storage zx:data be."$(uuid)".u0
$data modify storage zx:work be.snap.u1 set from storage zx:data be."$(uuid)".u1
$data modify storage zx:work be.snap.u2 set from storage zx:data be."$(uuid)".u2
$data modify storage zx:work be.snap.u3 set from storage zx:data be."$(uuid)".u3

$execute if entity $(arrow) if data entity $(arrow) data.zx.be{ok:1b} run data modify storage zx:work be.snap set from entity $(arrow) data.zx.be
