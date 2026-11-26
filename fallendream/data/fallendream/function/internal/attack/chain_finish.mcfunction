$execute unless data storage zx:combat chains."$(chain)" run return 0
scoreboard players set #ac_pending zx.meta 0
$execute store result score #ac_pending zx.meta run data get storage zx:combat chains."$(chain)".pending
scoreboard players remove #ac_pending zx.meta 1
execute if score #ac_pending zx.meta matches ..-1 run scoreboard players set #ac_pending zx.meta 0
$execute store result storage zx:combat chains."$(chain)".pending int 1 run scoreboard players get #ac_pending zx.meta
$function fallendream:internal/attack/chain_check with storage zx:combat chains."$(chain)"
