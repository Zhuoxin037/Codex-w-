data remove storage sweetdream:knight selected
$data modify storage sweetdream:knight selected set from storage sweetdream:knight targets."$(id)"
execute if data storage sweetdream:knight selected.uuid run return run function sweetdream:boss/knight/target/resolve with storage sweetdream:knight selected
execute if data storage sweetdream:knight selected.u0 run function sweetdream:boss/knight/target/resolve_legacy with storage sweetdream:knight selected
