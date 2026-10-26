# @s is the target; command position remains at the candle.
function sweetdream:lib/entity_id
$data modify storage zx:work bc_contact set value {cid:$(cid),end:$(end),tid:0}
execute store result storage zx:work bc_contact.tid int 1 run scoreboard players get @s zx.sid
scoreboard players set #bc_zone zx.meta 0
execute if entity @s[distance=..3] run scoreboard players set #bc_zone zx.meta 1
function sweetdream:equipment/armor/bright_candle/dwell_go with storage zx:work bc_contact
