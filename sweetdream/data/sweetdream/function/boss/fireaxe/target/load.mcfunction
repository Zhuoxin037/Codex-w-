data remove storage sweetdream:fireaxe selected
$data modify storage sweetdream:fireaxe selected set from storage sweetdream:fireaxe targets."$(id)"
execute if data storage sweetdream:fireaxe selected.u0 run function sweetdream:boss/fireaxe/target/resolve with storage sweetdream:fireaxe selected
