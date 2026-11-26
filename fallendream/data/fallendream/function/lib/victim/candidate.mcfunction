# Only a newly changed victim belongs to the current native hit. Old HurtTime:10
# candidates from already-settled splash/extra damage must not make it ambiguous.
data modify storage zx:work nh_snapshot set from entity @s
scoreboard players set #vx_prev zx.meta 0
scoreboard players set #vx_current zx.meta 0
scoreboard players set #vx_abs zx.meta 0
execute if score @s zx.nh_hp matches 0.. run scoreboard players operation #vx_prev zx.meta = @s zx.nh_hp
execute if score @s zx.nh_ab matches 0.. run scoreboard players operation #vx_prev zx.meta += @s zx.nh_ab
execute store result score #vx_current zx.meta run data get storage zx:work nh_snapshot.Health 1000
execute store result score #vx_abs zx.meta run data get storage zx:work nh_snapshot.AbsorptionAmount 1000
scoreboard players operation #vx_current zx.meta += #vx_abs zx.meta
execute if score @s zx.nh_hp matches 0.. if score #vx_current zx.meta >= #vx_prev zx.meta run return 0
scoreboard players add #vx_count zx.meta 1
execute unless score #vx_count zx.meta matches 1 run return 0
function fallendream:lib/entity_uuid/build
data modify storage zx:victim candidate.vx_uuid set from storage zx:work native_uuid.uuid
