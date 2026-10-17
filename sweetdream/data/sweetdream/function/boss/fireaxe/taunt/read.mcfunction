data remove storage sweetdream:fireaxe taunt_target
$data modify storage sweetdream:fireaxe taunt_target set from storage sweetdream:fireaxe targets."$(id)"
execute if data storage sweetdream:fireaxe taunt_target.u0 run function sweetdream:boss/fireaxe/taunt/owner with storage sweetdream:fireaxe taunt_target
