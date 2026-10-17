# ============================================================
# sweetdream:equipment/bow/reverse_string/apply —— 取出射手 uuid, 转交 fire(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work rs {target, shooter}
# 【执行者】被打中的那只生物(由 hook_victim 送进来)
# ============================================================

$execute as $(shooter) run function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work rs.uuid set from storage zx:data self.uuid
$execute as $(shooter) at @s run function sweetdream:equipment/bow/reverse_string/fire with storage zx:work rs
