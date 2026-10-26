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
execute store result score #mp_src zx.meta run data get storage manacore:out r.seg_x
scoreboard players operation #mp_mul zx.meta = #jawpct zx.meta
scoreboard players operation #mp_mul zx.meta *= #j10 zx.meta
scoreboard players add #mp_mul zx.meta 1000
function sweetdream:lib/math/mul_permille
execute store result storage manacore:out r.seg_x int 1 run scoreboard players get #mp_out zx.meta
