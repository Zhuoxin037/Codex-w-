# 坐标直接复制double；不使用非法的store ... string，也不截掉小数。
execute unless data storage zx:work cic_pos.start run return 0
data modify storage zx:work cic_s set from storage zx:work cic_pos
data modify storage zx:work cic_e set from storage zx:work cic_pos
data modify storage zx:work cic_s.x set from storage zx:work cic_pos.start[0]
data modify storage zx:work cic_s.y set from storage zx:work cic_pos.start[1]
data modify storage zx:work cic_s.z set from storage zx:work cic_pos.start[2]
data modify storage zx:work cic_e.x set from storage zx:work cic_pos.end[0]
data modify storage zx:work cic_e.y set from storage zx:work cic_pos.end[1]
data modify storage zx:work cic_e.z set from storage zx:work cic_pos.end[2]
function fallendream:equipment/armor/empty_cicada/ol_spawn with storage zx:work cic_s
function fallendream:equipment/armor/empty_cicada/ol_spawn with storage zx:work cic_e
scoreboard players set #s2_g_v zx.meta 12000
scoreboard players set #s2_g_t zx.meta 100
function fallendream:batch21/shield/grant
scoreboard players operation @s zx.thp_end = #now manacore.meta
scoreboard players add @s zx.thp_end 100
scoreboard players operation @s zx.s2_cicada_end = #now manacore.meta
scoreboard players add @s zx.s2_cicada_end 600
data remove storage zx:work cic_s
data remove storage zx:work cic_e
