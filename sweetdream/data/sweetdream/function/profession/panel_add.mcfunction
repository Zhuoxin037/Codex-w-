execute if score @s zx.job matches 1 if items entity @s armor.head *[custom_data~{zx:["eagle_hat"]}] run function sweetdream:profession/mage/hat_calc
execute unless score @s zx.job matches 1 run return 0
execute unless score @s zx.j_aw matches 1 run return 0
function sweetdream:profession/mage/tally
scoreboard players operation #jawpct zx.meta = #jorbs zx.meta
scoreboard players set #jthree zx.meta 3
scoreboard players operation #jawpct zx.meta *= #jthree zx.meta
execute store result storage zx:work put.pct int 1 run scoreboard players get #jawpct zx.meta
data modify storage zx:work put.ch set value "mm"
function sweetdream:lib/dmg_add_put with storage zx:work put
data modify storage zx:work put.ch set value "atk"
function sweetdream:lib/dmg_add_put with storage zx:work put
data modify storage zx:work put.ch set value "oth"
function sweetdream:lib/dmg_add_put with storage zx:work put
