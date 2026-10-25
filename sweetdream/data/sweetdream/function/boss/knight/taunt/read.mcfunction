data remove storage sweetdream:knight taunt_target
$data modify storage sweetdream:knight taunt_target set from storage sweetdream:knight targets."$(id)"
execute if data storage sweetdream:knight taunt_target.u0 run function sweetdream:boss/knight/taunt/owner with storage sweetdream:knight taunt_target
