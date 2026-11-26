data remove storage fallendream:knight taunt_target
$data modify storage fallendream:knight taunt_target set from storage fallendream:knight targets."$(id)"
execute if data storage fallendream:knight taunt_target.u0 run function fallendream:boss/knight/taunt/owner with storage fallendream:knight taunt_target
