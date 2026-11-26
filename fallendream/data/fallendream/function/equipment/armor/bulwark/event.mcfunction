data modify storage zx:work bw_events append value {amount:0}
execute store result storage zx:work bw_events[-1].amount int 1 run scoreboard players get @s zx.hurt_evt
function fallendream:equipment/armor/bulwark/hurt
execute store result score @s zx.hurt_evt run data get storage zx:work bw_events[-1].amount
data remove storage zx:work bw_events[-1]
