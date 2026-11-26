$execute unless data storage zx:combat chains."$(chain)" run return 0
scoreboard players set #ac_pending zx.meta 0
$execute store result score #ac_pending zx.meta run data get storage zx:combat chains."$(chain)".pending
scoreboard players add #ac_pending zx.meta 1
$execute store result storage zx:combat chains."$(chain)".pending int 1 run scoreboard players get #ac_pending zx.meta
