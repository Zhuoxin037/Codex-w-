# ============================================================
# sweetdream:equipment/bow/rainbow/apply —— 取出"射手这一发"的数据(宏 {target,shooter,arrow})
# ------------------------------------------------------------
# 【执行者】被打中的那只生物
# 【两层宏】先借 lib/uuid 拿射手 uuid, 再交给 fire。
# ============================================================

$execute as $(shooter) run function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work rb.uuid set from storage zx:data self.uuid
function sweetdream:equipment/bow/rainbow/snap_prep with storage zx:work rb
function sweetdream:equipment/bow/rainbow/fire with storage zx:work rb
