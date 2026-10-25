# ============================================================
# sweetdream:equipment/bow/lucid_dream/hit_extra_form_find —— 按 u0..u3 反查施法者(宏 {u0..u3})
# ------------------------------------------------------------
# 【谁调它】hit_extra_form ②(执行者不限)
# 【干什么】找到施法者 -> 刷新他的「清醒梦」术阵
# ============================================================

$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run function sweetdream:equipment/bow/lucid_dream/hit_extra_form_go
