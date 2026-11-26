
$execute if score #up_tc zx.meta matches 1.. if entity $(vx_uuid) run function fallendream:upgrade/api/torch
$execute if score #up_boil zx.meta matches 1.. if entity $(vx_uuid) run function fallendream:upgrade/api/boil

$tag $(vx_uuid) remove zx.victim
