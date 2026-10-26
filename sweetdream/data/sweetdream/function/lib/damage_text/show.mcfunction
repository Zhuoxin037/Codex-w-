# Display at most 128 simultaneous numbers; lifetime/cap only affect visuals.
execute if score #dt_count zx.meta matches 128.. run return 0
scoreboard players operation #dt_cent zx.meta = #dt_amount zx.meta
scoreboard players add #dt_cent zx.meta 5
scoreboard players operation #dt_cent zx.meta /= #10 zx.meta
execute if score #dt_cent zx.meta matches ..0 run scoreboard players set #dt_cent zx.meta 1
scoreboard players operation #dt_whole zx.meta = #dt_cent zx.meta
scoreboard players operation #dt_whole zx.meta /= #100 zx.meta
scoreboard players operation #dt_dec zx.meta = #dt_cent zx.meta
scoreboard players operation #dt_dec zx.meta %= #100 zx.meta
scoreboard players operation #dt_tens zx.meta = #dt_dec zx.meta
scoreboard players operation #dt_tens zx.meta /= #10 zx.meta
scoreboard players operation #dt_ones zx.meta = #dt_dec zx.meta
scoreboard players operation #dt_ones zx.meta %= #10 zx.meta
data modify storage zx:work dt_number set value {whole:0,tens:0,ones:0}
execute store result storage zx:work dt_number.whole int 1 run scoreboard players get #dt_whole zx.meta
execute store result storage zx:work dt_number.tens int 1 run scoreboard players get #dt_tens zx.meta
execute store result storage zx:work dt_number.ones int 1 run scoreboard players get #dt_ones zx.meta
function sweetdream:lib/damage_text/format with storage zx:work dt_number
