# ============================================================
# sweetdream:equipment/sword/profane/probe —— 剖线单点采样（执行位置 = 采样点）
# ------------------------------------------------------------
# 中心球 + 左右各 0.7 格（相对朝向旋转 ±90 后再前进 0.7）⇒ 一点覆盖宽 2 格。
# 只打标记、不算伤害：命中去重靠 zx.pf_hit 这一个 tag，结算是上层统一跑的。
# ============================================================
tag @e[type=!#sweetdream:no_damage,distance=..1.2] add zx.pf_hit
execute rotated ~90 0 positioned ^0.7 ^ ^ run tag @e[type=!#sweetdream:no_damage,distance=..1.2] add zx.pf_hit
execute rotated ~-90 0 positioned ^0.7 ^ ^ run tag @e[type=!#sweetdream:no_damage,distance=..1.2] add zx.pf_hit
