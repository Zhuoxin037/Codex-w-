data remove storage sweetdream:husk taunt_target
$data modify storage sweetdream:husk taunt_target set from storage sweetdream:husk targets."$(id)"
execute if data storage sweetdream:husk taunt_target.u0 run function sweetdream:boss/husk/taunt/owner with storage sweetdream:husk taunt_target
