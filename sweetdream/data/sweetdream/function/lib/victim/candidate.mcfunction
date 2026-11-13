scoreboard players add #vx_count zx.meta 1
execute unless score #vx_count zx.meta matches 1 run return 0
data modify storage zx:work nh_snapshot set from entity @s
function sweetdream:lib/entity_uuid/build
data modify storage zx:victim candidate.vx_uuid set from storage zx:work native_uuid.uuid
