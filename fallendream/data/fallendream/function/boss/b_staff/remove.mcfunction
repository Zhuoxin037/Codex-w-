$data modify storage fallendream:b_staff args set value {id:$(id)}
function fallendream:boss/b_staff/cleanup_cast with storage fallendream:b_staff args
function fallendream:boss/b_staff/bar/remove with storage fallendream:b_staff args
$data remove storage fallendream:b_staff targets."$(id)"
$kill @e[tag=sd.bs.bone,scores={bs.id=$(id)},distance=0..]
$kill @e[tag=sd.bs.body,scores={bs.id=$(id)},distance=0..]
$kill @e[tag=sd.bs.rig,scores={bs.id=$(id)},distance=0..]
