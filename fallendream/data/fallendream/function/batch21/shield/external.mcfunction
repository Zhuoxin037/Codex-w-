function fallendream:lib/uuid
data modify storage zx:work s2_shield set value {owner:""}
data modify storage zx:work s2_shield.owner set from storage zx:data self.uuid
function fallendream:batch21/shield/external_read with storage zx:work s2_shield
