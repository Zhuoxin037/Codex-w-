data remove storage fallendream:b_staff selected
$data modify storage fallendream:b_staff selected set from storage fallendream:b_staff targets."$(id)"
execute if data storage fallendream:b_staff selected.uuid run function fallendream:boss/b_staff/target/resolve with storage fallendream:b_staff selected
