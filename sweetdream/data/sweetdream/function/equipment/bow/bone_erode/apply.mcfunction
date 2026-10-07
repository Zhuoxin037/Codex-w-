# ============================================================
# sweetdream:equipment/bow/bone_erode/apply —— 取出"射手这一发"的数据(宏 {target,shooter,arrow})
# ------------------------------------------------------------
# 【执行者】被打中的那只生物
# 【两层宏】先借 lib/uuid 拿射手 uuid, 再交给 fire(路径里要用 uuid 字符串)。
# 【snap_prep】把"逐箭快照"和"射手最近一发"合成一份 be.snap, fire 只读一处。
# ============================================================

$execute as $(shooter) run function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work be.uuid set from storage zx:data self.uuid
function sweetdream:equipment/bow/bone_erode/snap_prep with storage zx:work be
function sweetdream:equipment/bow/bone_erode/fire with storage zx:work be
