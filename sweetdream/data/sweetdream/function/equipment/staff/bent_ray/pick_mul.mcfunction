# ============================================================
# sweetdream:equipment/staff/bent_ray/pick_mul —— 按段数取本段的独立乘区 1.2^n
# ------------------------------------------------------------
# 【谁调用它】chain ②   【入参】#br_n zx.meta = 当前是第几段连锁(0 = 首段)
# 【出参】zx:work brm.mul = 该段的 independent_multiplier
# 【为什么查表而不是算】data 命令不能做浮点乘法, 而"1.2 的 n 次方"又必须精确;
#   n 只可能是 0..6 这 7 个值, 直接写成 7 个字面量最稳(同 长夜 的 1.08^n 表)。
#   1.2^6 = 2.985984。
# 【为什么每次重写整个 brm】链是递归的, 上一段的值必须被覆盖, 否则 n 变大时会沿用旧值。
# ============================================================

data modify storage zx:work brm set value {m0:1.0,m1:1.2,m2:1.44,m3:1.728,m4:2.0736,m5:2.48832,m6:2.985984}
data modify storage zx:work brm.mul set from storage zx:work brm.m0
execute if score #br_n zx.meta matches 1 run data modify storage zx:work brm.mul set from storage zx:work brm.m1
execute if score #br_n zx.meta matches 2 run data modify storage zx:work brm.mul set from storage zx:work brm.m2
execute if score #br_n zx.meta matches 3 run data modify storage zx:work brm.mul set from storage zx:work brm.m3
execute if score #br_n zx.meta matches 4 run data modify storage zx:work brm.mul set from storage zx:work brm.m4
execute if score #br_n zx.meta matches 5 run data modify storage zx:work brm.mul set from storage zx:work brm.m5
execute if score #br_n zx.meta matches 6 run data modify storage zx:work brm.mul set from storage zx:work brm.m6
