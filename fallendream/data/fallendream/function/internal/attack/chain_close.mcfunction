$execute unless data storage zx:combat chains."$(chain)" run return 0
$data modify storage zx:combat chains."$(chain)".closed set value 1b
$function fallendream:internal/attack/chain_check with storage zx:combat chains."$(chain)"
