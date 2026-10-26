# Read-only pending bonus. Used by both actual calculation and self-stat scan.
execute unless score @s zx.pf_mul matches 1.. run return 0
execute unless score @s zx.pf_mn matches 1.. run return 0
execute store result storage zx:work put.pct int 1 run scoreboard players get @s zx.pf_mul
data modify storage zx:work put.ch set value "oth"
function sweetdream:lib/dmg_add_put with storage zx:work put
