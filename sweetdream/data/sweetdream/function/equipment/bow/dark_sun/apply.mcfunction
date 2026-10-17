# ============================================================
# sweetdream:equipment/bow/dark_sun/apply —— 取出射手 uuid, 转交 fire(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work ds {target, shooter}
# 【执行者】被打中的那只生物(由 hook_victim 送进来)
# ============================================================

$execute as $(shooter) run function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work ds.uuid set from storage zx:data self.uuid
$execute as $(shooter) at @s run function sweetdream:equipment/bow/dark_sun/fire with storage zx:work ds
