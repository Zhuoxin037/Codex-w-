# ============================================================
# sweetdream:equipment/staff/bent_ray/pick_mul —— 按段数取本段的独立乘区 1.2^n
# ------------------------------------------------------------
# 【谁调用它】chain ② / ol_end ①   【入参】#br_n zx.meta = 当前是第几段连锁(0 = 首段)
# 【出参】zx:work brm.mul = 该段的 independent_multiplier
# 【为什么查表而不是算】data 命令不能做浮点乘法, 而"1.2 的 n 次方"又必须精确;
#   n 只可能是 0..8 这 9 个值, 直接写成 9 个字面量最稳(同 长夜 的 1.08^n 表)。
#   1.2^6 = 2.985984 / 1.2^7 = 3.5831808 / 1.2^8 = 4.29981696。
# 【为什么表里要有 m7 / m8】超限·折径的连锁上限 6→**8**(2026-10-23 批 K9) ⇒
#   段号能走到 8; 表里没有这两档的话, 第 8 段会**沿用 m0**(下面第 13 行的初值)
#   ⇒ 末段乘区从 ×4.3 掉回 ×1.0, 整条链最后一段白打 —— 静默、零日志。
# 【为什么每次重写整个 brm】链是递归的, 上一段的值必须被覆盖, 否则 n 变大时会沿用旧值。
# ============================================================

data modify storage zx:work brm set value {m0:1.0,m1:1.2,m2:1.44,m3:1.728,m4:2.0736,m5:2.48832,m6:2.985984,m7:3.5831808,m8:4.29981696}
data modify storage zx:work brm.mul set from storage zx:work brm.m0
execute if score #br_n zx.meta matches 1 run data modify storage zx:work brm.mul set from storage zx:work brm.m1
execute if score #br_n zx.meta matches 2 run data modify storage zx:work brm.mul set from storage zx:work brm.m2
execute if score #br_n zx.meta matches 3 run data modify storage zx:work brm.mul set from storage zx:work brm.m3
execute if score #br_n zx.meta matches 4 run data modify storage zx:work brm.mul set from storage zx:work brm.m4
execute if score #br_n zx.meta matches 5 run data modify storage zx:work brm.mul set from storage zx:work brm.m5
execute if score #br_n zx.meta matches 6 run data modify storage zx:work brm.mul set from storage zx:work brm.m6
execute if score #br_n zx.meta matches 7 run data modify storage zx:work brm.mul set from storage zx:work brm.m7
execute if score #br_n zx.meta matches 8.. run data modify storage zx:work brm.mul set from storage zx:work brm.m8
