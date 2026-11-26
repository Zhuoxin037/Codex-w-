$data modify storage zx:rogue p."$(uuid)".home set value {}
$data modify storage zx:rogue p."$(uuid)".home.dim set from entity @s Dimension
$data modify storage zx:rogue p."$(uuid)".home.x set from entity @s Pos[0]
$data modify storage zx:rogue p."$(uuid)".home.y set from entity @s Pos[1]
$data modify storage zx:rogue p."$(uuid)".home.z set from entity @s Pos[2]
$data modify storage zx:rogue p."$(uuid)".home.yaw set from entity @s Rotation[0]
$data modify storage zx:rogue p."$(uuid)".home.pitch set from entity @s Rotation[1]
