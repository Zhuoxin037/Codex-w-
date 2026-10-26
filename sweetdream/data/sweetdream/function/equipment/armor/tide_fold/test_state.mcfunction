$execute unless entity @e[tag=zx.tf_prev,distance=0..,scores={zx.sid=$(sid)},limit=1] at @s run function sweetdream:equipment/armor/tide_fold/previous_new {sid:$(sid)}
$scoreboard players operation @e[tag=zx.tf_prev,distance=0..,scores={zx.sid=$(sid)},limit=1] zx.tf_seen = #now manacore.meta
$execute unless data storage zx:work tf_cross.e$(sid) run data modify storage zx:work tf_cross.e$(sid) set value {side:0,tick:-1}
scoreboard players set #tf_old_side zx.meta 0
scoreboard players set #tf_old_tick zx.meta -1
$execute store result score #tf_old_side zx.meta run data get storage zx:work tf_cross.e$(sid).side
$execute store result score #tf_old_tick zx.meta run data get storage zx:work tf_cross.e$(sid).tick
$execute store result storage zx:work tf_cross.e$(sid).tick int 1 run scoreboard players get #now manacore.meta
$execute unless score #tf_side zx.meta matches 0 store result storage zx:work tf_cross.e$(sid).side int 1 run scoreboard players get #tf_side zx.meta
execute if score #tf_side zx.meta matches 0 run return 0
execute if score #tf_old_side zx.meta matches 0 run return 0
execute if score #tf_side zx.meta = #tf_old_side zx.meta run return 0
scoreboard players operation #tf_last_tick zx.meta = #now manacore.meta
scoreboard players remove #tf_last_tick zx.meta 1
execute unless score #tf_old_tick zx.meta = #tf_last_tick zx.meta run return 0
scoreboard players set #tf_fresh zx.meta 0
$execute as @e[tag=zx.tf_prev,distance=0..,scores={zx.sid=$(sid)},limit=1] if score @s zx.tf_born = #now manacore.meta run scoreboard players set #tf_fresh zx.meta 1
execute if score #tf_fresh zx.meta matches 1 run return 0
# Discontinuous world-scale teleports are outside the bounded physical-motion solver.
execute unless entity @s[distance=..8192] run return 0
function sweetdream:equipment/armor/tide_fold/intersection with storage zx:work tf_pair
