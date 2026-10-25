# ============================================================
# sweetdream:equipment/axe/grave_tablet/probe —— 裂口单点采样（执行位置 = 采样点）
# 中心 + 左右各 1.5 格，判定半径 1.5 ⇒ "裂口上及两侧 1.5 格"。
# ============================================================
tag @e[type=!#sweetdream:no_damage,distance=..1.5] add zx.gt_hit
execute rotated ~90 0 positioned ^1.5 ^ ^ run tag @e[type=!#sweetdream:no_damage,distance=..1.5] add zx.gt_hit
execute rotated ~-90 0 positioned ^1.5 ^ ^ run tag @e[type=!#sweetdream:no_damage,distance=..1.5] add zx.gt_hit
