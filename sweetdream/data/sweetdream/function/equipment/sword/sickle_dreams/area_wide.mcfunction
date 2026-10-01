# ============================================================
# sweetdream:equipment/sword/sickle_dreams/area_wide —— 圈出强化版的"前方 3*5"
# ------------------------------------------------------------
# 和 area_base 同一套写法, 只是盒子更大(视线前方 2.5 格处、边长 4.0)。
# ============================================================

execute anchored eyes positioned ^ ^ ^2.5 positioned ~-2.0 ~-2.0 ~-2.0 run tag @e[type=!#sweetdream:no_damage,dx=4.0,dy=4.0,dz=4.0] add zx.sd_hit
