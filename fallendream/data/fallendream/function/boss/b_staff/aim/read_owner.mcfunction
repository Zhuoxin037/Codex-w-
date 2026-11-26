data modify storage fallendream:b_staff aim set value {yaw:0f,pitch:0f}
$data modify storage fallendream:b_staff aim.yaw set from storage fallendream:b_staff poses."$(id)".aim[0]
$data modify storage fallendream:b_staff aim.pitch set from storage fallendream:b_staff poses."$(id)".aim[1]
