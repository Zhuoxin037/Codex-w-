execute if score #i manacore.meta >= #max_slots manacore.meta run return 0
execute store result storage manacore:work rc.i int 1 run scoreboard players get #i manacore.meta
function manacore:internal/debug/slot_recount_one with storage manacore:work rc
scoreboard players add #i manacore.meta 1
function manacore:internal/debug/slot_recount_loop