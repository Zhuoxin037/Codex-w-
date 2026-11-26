scoreboard players set #ac_primary zx.meta 0
$execute store result score #ac_primary zx.meta run data get storage zx:combat chains."$(chain)".primary
$scoreboard players set #ac_primary_add zx.meta $(actual)
scoreboard players set #ac_room zx.meta 2147483647
scoreboard players operation #ac_room zx.meta -= #ac_primary zx.meta
execute if score #ac_primary_add zx.meta > #ac_room zx.meta run scoreboard players operation #ac_primary_add zx.meta = #ac_room zx.meta
scoreboard players operation #ac_primary zx.meta += #ac_primary_add zx.meta
$execute store result storage zx:combat chains."$(chain)".primary int 1 run scoreboard players get #ac_primary zx.meta
$execute as $(vx_uuid) at @s run function fallendream:internal/attack/chain_center {chain:$(chain)}
