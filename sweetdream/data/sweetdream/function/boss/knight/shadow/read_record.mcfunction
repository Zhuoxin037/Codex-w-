data remove storage sweetdream:knight shadow_args
$data modify storage sweetdream:knight shadow_args set from storage sweetdream:knight shadow_rigs."$(serial)"
execute unless data storage sweetdream:knight shadow_args.ghost_uuid run return run function sweetdream:boss/knight/shadow/end
function sweetdream:boss/knight/shadow/with_owner with storage sweetdream:knight shadow_args
