# ============================================================
# sweetdream:equipment/bow/lucid_dream/find_shooter —— 按 u0..u3 反查射手并读其当前魔力(宏 {u0..u3})
# ------------------------------------------------------------
# 【谁调它】big ②(执行者不限)
# 【产出】#ld_mana zx.meta = 射手当前魔力值; 查不到人则保持 0。
# ============================================================

$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run function sweetdream:equipment/bow/lucid_dream/find_shooter_go
