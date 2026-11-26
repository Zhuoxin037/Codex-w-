execute unless score #fox8_left zx.meta matches 1.. run return 0
scoreboard players remove #fox8_left zx.meta 1
data modify storage zx:work a set from storage zx:work fox8.attack
function fallendream:internal/attack/submit_skill
execute if score #fox8_left zx.meta matches 1.. run function fallendream:equipment/staff/eight_tail/repeat
