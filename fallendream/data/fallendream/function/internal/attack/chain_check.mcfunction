$execute unless data storage zx:combat chains."$(chain)"{closed:1b,pending:0} run return 0
$data modify storage zx:work ub set from storage zx:combat chains."$(chain)"
function fallendream:lib/u_by
$execute as @a[tag=zx.ub,limit=1] unless data storage zx:combat chains."$(chain)"{spread:1b} run function fallendream:internal/attack/chain_spread with storage zx:combat chains."$(chain)"
$data modify storage zx:work ub set from storage zx:combat chains."$(chain)"
function fallendream:lib/u_by
$execute as @a[tag=zx.ub,limit=1] run function fallendream:internal/attack/chain_settle with storage zx:combat chains."$(chain)"
$data remove storage zx:combat chains."$(chain)"
