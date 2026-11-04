function sweetdream:lib/uuid
data modify storage zx:work s2_shield set value {owner:""}
data modify storage zx:work s2_shield.owner set from storage zx:data self.uuid
function sweetdream:batch21/shield/read with storage zx:work s2_shield
scoreboard players operation #s2_target zx.meta = #s2_cur zx.meta
scoreboard players operation #s2_target zx.meta -= #s2_expired zx.meta
scoreboard players operation #s2_target zx.meta += #s2_g_v zx.meta
data modify storage zx:work s2_entry set value {end:0,amount:0}
scoreboard players operation #s2_due zx.meta = #now manacore.meta
scoreboard players operation #s2_due zx.meta += #s2_g_t zx.meta
execute store result storage zx:work s2_entry.end int 1 run scoreboard players get #s2_due zx.meta
execute store result storage zx:work s2_entry.amount int 1 run scoreboard players get #s2_g_v zx.meta
data modify storage zx:work s2_keep append from storage zx:work s2_entry
function sweetdream:batch21/shield/commit with storage zx:work s2_shield
