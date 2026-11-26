execute store result score #rd_size zx.meta run data get storage zx:rogue floor.unassigned
execute if score #rd_size zx.meta matches 0 run return 0
scoreboard players remove #rd_size zx.meta 1
data modify storage zx:work rd_pick set value {}
execute store result storage zx:work rd_pick.max int 1 run scoreboard players get #rd_size zx.meta
function fallendream:rogue/gen/random with storage zx:work rd_pick
$data modify storage zx:work rd_pick.kind set value "$(kind)"
function fallendream:rogue/gen/assign_pick with storage zx:work rd_pick
