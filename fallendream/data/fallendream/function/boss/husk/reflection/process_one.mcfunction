$execute unless data storage fallendream:husk queues."$(id)"[0] run return 0
tag @s add sd.hk.reflect_source
$data modify storage fallendream:husk ref_current set from storage fallendream:husk queues."$(id)"[0]
$data modify storage fallendream:husk ref_current.id set value $(id)
function fallendream:boss/husk/reflection/resolve with storage fallendream:husk ref_current
$data remove storage fallendream:husk queues."$(id)"[0]
tag @s remove sd.hk.reflect_source
$execute if data storage fallendream:husk queues."$(id)"[0] run function fallendream:boss/husk/reflection/process_one {id:$(id)}
