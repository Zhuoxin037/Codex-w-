function fallendream:profession/twin/record
function fallendream:profession/twin/locate
function fallendream:profession/twin/snapshot_twin with storage zx:work jt
# Park the twin at exactly the departure position.
execute unless score @s zx.j_reborn matches 1.. run function fallendream:profession/twin/park
function fallendream:profession/twin/unguard
scoreboard players set @s zx.j_form 0
tag @s remove zx.j_twin_live
function fallendream:profession/stats
function fallendream:profession/twin/restore_body with storage zx:work jt
execute as @e[tag=zx.j_anchor,distance=0..] run function fallendream:profession/twin/despawn

function fallendream:profession/twin/release
