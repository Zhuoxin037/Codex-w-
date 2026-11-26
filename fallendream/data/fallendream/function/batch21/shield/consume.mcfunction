execute unless score #s2_lost zx.meta matches 1.. run return 0
execute unless data storage zx:work s2_queue[0] run return 0
execute store result score #s2_amount zx.meta run data get storage zx:work s2_queue[0].amount
execute if score #s2_lost zx.meta >= #s2_amount zx.meta run return run function fallendream:batch21/shield/consume_full
scoreboard players operation #s2_amount zx.meta -= #s2_lost zx.meta
execute store result storage zx:work s2_queue[0].amount int 1 run scoreboard players get #s2_amount zx.meta
scoreboard players set #s2_lost zx.meta 0
