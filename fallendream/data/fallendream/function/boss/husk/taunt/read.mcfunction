data remove storage fallendream:husk taunt_target
$data modify storage fallendream:husk taunt_target set from storage fallendream:husk targets."$(id)"
execute if data storage fallendream:husk taunt_target.u0 run function fallendream:boss/husk/taunt/owner with storage fallendream:husk taunt_target
