# ============================================================
# sweetdream:equipment/bow/lucid_dream/hit_extra_hit —— 对单个生物打范围真伤
# ------------------------------------------------------------
# 【谁调它】hit_extra_dmg ④: `execute as @e[...] run function ... with storage zx:work a`
#   所以执行者 = 这一只范围内的生物。
# 【怎么打】把 a.target 设成 @s, 交给 with_from(它内部再 as $(target) -> @s)。
# ============================================================

data modify storage zx:work a.target set value "@s"
function sweetdream:internal/damage/with_from with storage zx:work a
