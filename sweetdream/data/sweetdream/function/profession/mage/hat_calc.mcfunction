function sweetdream:profession/mage/tally
scoreboard players operation #jhatpct zx.meta = #jorbs zx.meta
scoreboard players operation #jhatpct zx.meta *= #j5 zx.meta
scoreboard players add #jhatpct zx.meta 10
execute store result storage zx:work put.pct int 1 run scoreboard players get #jhatpct zx.meta
data modify storage zx:work put.ch set value "mm"
function sweetdream:lib/dmg_add_put with storage zx:work put
