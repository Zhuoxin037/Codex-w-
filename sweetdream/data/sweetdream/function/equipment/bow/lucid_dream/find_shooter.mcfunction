# ============================================================
# sweetdream:equipment/bow/lucid_dream/find_shooter —— 按 u0..u3 反查射手并读其当前魔力(宏 {u0..u3})
# ------------------------------------------------------------
# 【谁调它】big ②(执行者不限)
# 【产出】#ld_mana zx.meta = 射手当前魔力值; 查不到人则保持 0。
# ============================================================

$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run function sweetdream:equipment/bow/lucid_dream/find_shooter_go
