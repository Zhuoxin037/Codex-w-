# ============================================================
# sweetdream:equipment/bow/lucid_dream/hit_extra_find —— 按 u0..u3 反查施法者, 读其 max_mana(宏 {u0..u3})
# ------------------------------------------------------------
# 【谁调它】hit_extra_dmg ②(执行者不限)
# 【产出】#ld_mm zx.meta = 施法者 max_mana(整数, 面板原量纲); 查不到则 0。
# ============================================================

$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run function sweetdream:equipment/bow/lucid_dream/hit_extra_find_go
