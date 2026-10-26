function sweetdream:profession/twin/record
function sweetdream:profession/twin/locate
function sweetdream:profession/twin/snapshot_twin with storage zx:work jt
# Park the twin at exactly the departure position.
execute unless score @s zx.j_reborn matches 1.. run function sweetdream:profession/twin/park
function sweetdream:profession/twin/unguard
scoreboard players set @s zx.j_form 0
tag @s remove zx.j_twin_live
function sweetdream:profession/stats
function sweetdream:profession/twin/restore_body with storage zx:work jt
kill @e[tag=zx.j_anchor,distance=0..]

function sweetdream:profession/twin/release
