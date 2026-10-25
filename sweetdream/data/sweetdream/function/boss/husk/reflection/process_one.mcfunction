$execute unless data storage sweetdream:husk queues."$(id)"[0] run return 0
tag @s add sd.hk.reflect_source
$data modify storage sweetdream:husk ref_current set from storage sweetdream:husk queues."$(id)"[0]
$data modify storage sweetdream:husk ref_current.id set value $(id)
function sweetdream:boss/husk/reflection/resolve with storage sweetdream:husk ref_current
$data remove storage sweetdream:husk queues."$(id)"[0]
tag @s remove sd.hk.reflect_source
$execute if data storage sweetdream:husk queues."$(id)"[0] run function sweetdream:boss/husk/reflection/process_one {id:$(id)}
