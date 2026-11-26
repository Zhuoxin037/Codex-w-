data remove storage fallendream:knight selected
$data modify storage fallendream:knight selected set from storage fallendream:knight targets."$(id)"
execute if data storage fallendream:knight selected.uuid run return run function fallendream:boss/knight/target/resolve with storage fallendream:knight selected
execute if data storage fallendream:knight selected.u0 run function fallendream:boss/knight/target/resolve_legacy with storage fallendream:knight selected
