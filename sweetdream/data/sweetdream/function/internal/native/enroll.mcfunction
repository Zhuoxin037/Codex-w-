scoreboard players add #native_gen zx.meta 0
execute if score @s zx.native_gen = #native_gen zx.meta run return 0
execute unless data storage zx:native registry run data modify storage zx:native registry set value []
data modify storage zx:work nh_snapshot set from entity @s
function sweetdream:lib/entity_uuid/build
data modify storage zx:native registry append from storage zx:work native_uuid
tag @s add zx.native_known

scoreboard players operation @s zx.native_gen = #native_gen zx.meta
