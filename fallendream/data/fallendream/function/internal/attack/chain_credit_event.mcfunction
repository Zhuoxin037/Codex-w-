$execute unless data storage zx:combat chains."$(chain)" run return 0
scoreboard players set #ac_total zx.meta 0
$execute store result score #ac_total zx.meta run data get storage zx:combat chains."$(chain)".total
$scoreboard players set #ac_add zx.meta $(actual)
execute if score #ac_add zx.meta matches ..0 run return 0
scoreboard players set #ac_room zx.meta 2147483647
scoreboard players operation #ac_room zx.meta -= #ac_total zx.meta
execute if score #ac_add zx.meta > #ac_room zx.meta run scoreboard players operation #ac_add zx.meta = #ac_room zx.meta
scoreboard players operation #ac_total zx.meta += #ac_add zx.meta
$execute store result storage zx:combat chains."$(chain)".total int 1 run scoreboard players get #ac_total zx.meta
$execute if data storage zx:combat chains."$(chain)"{main:"$(vx_uuid)"} run function fallendream:internal/attack/chain_primary {chain:$(chain),actual:$(actual),vx_uuid:"$(vx_uuid)"}
