# dup-ok: repeated identical records encode weights.
execute unless data storage zx:rogue floor.unassigned[0] run return 0
data modify storage zx:rogue floor.candidates set value []
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:0}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:1}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:2}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:3}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:4}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:5}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:6}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:7}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:8}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:9}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:10}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:11}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:12}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:13}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:14}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:15}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:16}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:17}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:18}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:19}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:20}
execute if score #rd_k_combat zx.meta matches ..98 run data modify storage zx:rogue floor.candidates append value {kind:"combat",weight_slot:21}
execute if score #rd_k_elite zx.meta matches ..1 run data modify storage zx:rogue floor.candidates append value {kind:"elite",weight_slot:0}
execute if score #rd_k_elite zx.meta matches ..1 run data modify storage zx:rogue floor.candidates append value {kind:"elite",weight_slot:1}
execute if score #rd_k_elite zx.meta matches ..1 run data modify storage zx:rogue floor.candidates append value {kind:"elite",weight_slot:2}
execute if score #rd_k_elite zx.meta matches ..1 run data modify storage zx:rogue floor.candidates append value {kind:"elite",weight_slot:3}
execute if score #rd_k_elite zx.meta matches ..1 run data modify storage zx:rogue floor.candidates append value {kind:"elite",weight_slot:4}
execute if score #rd_k_safe zx.meta matches ..0 run data modify storage zx:rogue floor.candidates append value {kind:"safe",weight_slot:0}
execute if score #rd_k_safe zx.meta matches ..0 run data modify storage zx:rogue floor.candidates append value {kind:"safe",weight_slot:1}
execute if score #rd_k_merchant zx.meta matches ..0 if score #rd_commerce zx.meta matches ..1 run data modify storage zx:rogue floor.candidates append value {kind:"merchant",weight_slot:0}
execute if score #rd_k_merchant zx.meta matches ..0 if score #rd_commerce zx.meta matches ..1 run data modify storage zx:rogue floor.candidates append value {kind:"merchant",weight_slot:1}
execute if score #rd_k_event zx.meta matches ..2 run data modify storage zx:rogue floor.candidates append value {kind:"event",weight_slot:0}
execute if score #rd_k_event zx.meta matches ..2 run data modify storage zx:rogue floor.candidates append value {kind:"event",weight_slot:1}
execute if score #rd_k_event zx.meta matches ..2 run data modify storage zx:rogue floor.candidates append value {kind:"event",weight_slot:2}
execute if score #rd_k_event zx.meta matches ..2 run data modify storage zx:rogue floor.candidates append value {kind:"event",weight_slot:3}
execute if score #rd_k_event zx.meta matches ..2 run data modify storage zx:rogue floor.candidates append value {kind:"event",weight_slot:4}
execute if score #rd_k_forge zx.meta matches ..0 run data modify storage zx:rogue floor.candidates append value {kind:"forge",weight_slot:0}
execute if score #rd_k_forge zx.meta matches ..0 run data modify storage zx:rogue floor.candidates append value {kind:"forge",weight_slot:1}
execute if score #rd_k_astrology zx.meta matches ..0 run data modify storage zx:rogue floor.candidates append value {kind:"astrology",weight_slot:0}
execute if score #rd_k_astrology zx.meta matches ..0 run data modify storage zx:rogue floor.candidates append value {kind:"astrology",weight_slot:1}
execute if score #rd_k_gamble zx.meta matches ..0 run data modify storage zx:rogue floor.candidates append value {kind:"gamble",weight_slot:0}
execute if score #rd_k_gamble zx.meta matches ..0 run data modify storage zx:rogue floor.candidates append value {kind:"gamble",weight_slot:1}
execute if score #rd_k_rental zx.meta matches ..0 if score #rd_commerce zx.meta matches ..1 run data modify storage zx:rogue floor.candidates append value {kind:"rental",weight_slot:0}
execute if score #rd_k_blackmarket zx.meta matches ..0 if score #rd_commerce zx.meta matches ..1 run data modify storage zx:rogue floor.candidates append value {kind:"blackmarket",weight_slot:0}
execute store result score #rd_size zx.meta run data get storage zx:rogue floor.candidates
scoreboard players remove #rd_size zx.meta 1
data modify storage zx:work rd_pick set value {}
execute store result storage zx:work rd_pick.max int 1 run scoreboard players get #rd_size zx.meta
function sweetdream:rogue/gen/random with storage zx:work rd_pick
function sweetdream:rogue/gen/pick with storage zx:work rd_pick
function sweetdream:rogue/gen/assign_one with storage zx:work rd_chosen
function sweetdream:rogue/gen/assign_rest
