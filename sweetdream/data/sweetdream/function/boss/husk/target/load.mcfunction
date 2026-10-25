data remove storage sweetdream:husk selected
$data modify storage sweetdream:husk selected set from storage sweetdream:husk targets."$(id)"
execute if data storage sweetdream:husk selected.uuid run return run function sweetdream:boss/husk/target/resolve with storage sweetdream:husk selected
execute if data storage sweetdream:husk selected.u0 run function sweetdream:boss/husk/target/resolve_legacy with storage sweetdream:husk selected
