function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:anchor key set value {uuid:""}
data modify storage zx:anchor key.uuid set from storage zx:data self.uuid
function fallendream:equipment/axe/anchor/pull_tick_owner with storage zx:anchor key
