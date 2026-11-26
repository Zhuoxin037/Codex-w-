data remove storage fallendream:knight shadow_args
$data modify storage fallendream:knight shadow_args set from storage fallendream:knight shadow_rigs."$(serial)"
execute unless data storage fallendream:knight shadow_args.ghost_uuid run return run function fallendream:boss/knight/shadow/end
function fallendream:boss/knight/shadow/with_owner with storage fallendream:knight shadow_args
