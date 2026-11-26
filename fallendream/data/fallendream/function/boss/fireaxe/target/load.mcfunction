data remove storage fallendream:fireaxe selected
$data modify storage fallendream:fireaxe selected set from storage fallendream:fireaxe targets."$(id)"
execute if data storage fallendream:fireaxe selected.uuid run function fallendream:boss/fireaxe/target/resolve with storage fallendream:fireaxe selected
execute unless data storage fallendream:fireaxe selected.uuid if data storage fallendream:fireaxe selected.u0 run function fallendream:boss/fireaxe/target/resolve_legacy with storage fallendream:fireaxe selected
