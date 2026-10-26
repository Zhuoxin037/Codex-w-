data modify storage zx:uuid_entity a set value {hex:""}
data modify storage zx:uuid_entity a.value set from storage zx:work nh_snapshot.UUID[0]
function sweetdream:lib/entity_uuid/nibbles
function sweetdream:lib/entity_uuid/emit8
data modify storage zx:uuid_entity a.value set from storage zx:work nh_snapshot.UUID[1]
function sweetdream:lib/entity_uuid/nibbles
function sweetdream:lib/entity_uuid/emit8
data modify storage zx:uuid_entity a.value set from storage zx:work nh_snapshot.UUID[2]
function sweetdream:lib/entity_uuid/nibbles
function sweetdream:lib/entity_uuid/emit8
data modify storage zx:uuid_entity a.value set from storage zx:work nh_snapshot.UUID[3]
function sweetdream:lib/entity_uuid/nibbles
function sweetdream:lib/entity_uuid/emit8
data modify storage zx:uuid_entity a.h0 set string storage zx:uuid_entity a.hex 0 8
data modify storage zx:uuid_entity a.h1 set string storage zx:uuid_entity a.hex 8 12
data modify storage zx:uuid_entity a.h2 set string storage zx:uuid_entity a.hex 12 16
data modify storage zx:uuid_entity a.h3 set string storage zx:uuid_entity a.hex 16 20
data modify storage zx:uuid_entity a.h4 set string storage zx:uuid_entity a.hex 20 32
function sweetdream:lib/entity_uuid/join with storage zx:uuid_entity a
