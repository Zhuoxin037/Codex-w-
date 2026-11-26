scoreboard players add #native_gen zx.meta 0
execute if score @s zx.native_gen = #native_gen zx.meta run return 0
execute unless data storage zx:native registry run data modify storage zx:native registry set value []
data modify storage zx:work nh_snapshot set from entity @s
function fallendream:lib/entity_uuid/build
data modify storage zx:native registry append from storage zx:work native_uuid
tag @s add zx.native_known

scoreboard players operation @s zx.native_gen = #native_gen zx.meta
execute store result score @s zx.nh_hp run data get storage zx:work nh_snapshot.Health 1000
scoreboard players set @s zx.nh_ab 0
scoreboard players set @s zx.nh_stamp 0
execute store result score @s zx.nh_ab run data get storage zx:work nh_snapshot.AbsorptionAmount 1000
execute store result score @s zx.nh_stamp run data get storage zx:work nh_snapshot.ticks_since_last_hurt_by_mob
