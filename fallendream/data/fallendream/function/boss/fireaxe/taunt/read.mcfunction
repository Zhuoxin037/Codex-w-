data remove storage fallendream:fireaxe taunt_target
$data modify storage fallendream:fireaxe taunt_target set from storage fallendream:fireaxe targets."$(id)"
execute if data storage fallendream:fireaxe taunt_target.u0 run function fallendream:boss/fireaxe/taunt/owner with storage fallendream:fireaxe taunt_target
