function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work rg_return set value {}
data modify storage zx:work rg_return.uuid set from storage zx:data self.uuid
function fallendream:rogue/map/return_scan with storage zx:work rg_return
