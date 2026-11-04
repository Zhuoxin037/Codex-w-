function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work rg set value {slot:"weapon.offhand"}
data modify storage zx:work rg.uuid set from storage zx:data self.uuid
return run function sweetdream:rogue/prep/restore_off_go with storage zx:work rg
