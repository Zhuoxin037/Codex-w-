data remove storage fallendream:husk selected
$data modify storage fallendream:husk selected set from storage fallendream:husk targets."$(id)"
execute if data storage fallendream:husk selected.uuid run return run function fallendream:boss/husk/target/resolve with storage fallendream:husk selected
execute if data storage fallendream:husk selected.u0 run function fallendream:boss/husk/target/resolve_legacy with storage fallendream:husk selected
