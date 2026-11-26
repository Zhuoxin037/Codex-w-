function fallendream:lib/uuid
data modify storage zx:work s2_shield set value {owner:""}
data modify storage zx:work s2_shield.owner set from storage zx:data self.uuid
function fallendream:batch21/shield/read with storage zx:work s2_shield
scoreboard players operation #s2_target zx.meta = #s2_cur zx.meta
scoreboard players operation #s2_target zx.meta -= #s2_expired zx.meta
function fallendream:batch21/shield/commit with storage zx:work s2_shield
