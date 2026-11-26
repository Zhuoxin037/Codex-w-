# manacore uses an undashed UUID storage key. Convert it before vanilla entity arguments.
data modify storage fallendream:husk player_uuid set value ""
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage fallendream:husk uuid_parts.a set string storage zx:data self.uuid 0 8
data modify storage fallendream:husk uuid_parts.b set string storage zx:data self.uuid 8 12
data modify storage fallendream:husk uuid_parts.c set string storage zx:data self.uuid 12 16
data modify storage fallendream:husk uuid_parts.d set string storage zx:data self.uuid 16 20
data modify storage fallendream:husk uuid_parts.e set string storage zx:data self.uuid 20 32
function fallendream:boss/husk/uuid/join with storage fallendream:husk uuid_parts
