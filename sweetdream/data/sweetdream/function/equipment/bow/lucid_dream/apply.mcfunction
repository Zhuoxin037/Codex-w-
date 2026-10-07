# ============================================================
# sweetdream:equipment/bow/lucid_dream/apply —— 取出"射手这一发"(宏 {target,shooter,arrow})
# ============================================================

$execute as $(shooter) run function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work ld.uuid set from storage zx:data self.uuid
function sweetdream:equipment/bow/lucid_dream/snap_prep with storage zx:work ld
function sweetdream:equipment/bow/lucid_dream/fire with storage zx:work ld
