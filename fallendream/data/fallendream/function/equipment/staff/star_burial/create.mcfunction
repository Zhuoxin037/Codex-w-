data modify storage zx:work nh_snapshot set from entity @s
function fallendream:lib/entity_uuid/build
data modify storage zx:work burial_create.target set from storage zx:work native_uuid.uuid
summon minecraft:marker ~ ~ ~ {Tags:["zx.burial_core","zx.burial_new"],data:{}}
data modify entity @e[tag=zx.burial_new,distance=0..,limit=1] data set from storage zx:work burial_create
scoreboard players operation @e[tag=zx.burial_new,distance=0..,limit=1] zx.burial_cap = #burial_cap zx.meta
scoreboard players set @e[tag=zx.burial_new,distance=0..,limit=1] zx.burial_val 0
scoreboard players operation @e[tag=zx.burial_new,distance=0..,limit=1] zx.burial_end = #now manacore.meta
scoreboard players add @e[tag=zx.burial_new,distance=0..,limit=1] zx.burial_end 140
execute store result score @e[tag=zx.burial_new,distance=0..,limit=1] zx.burial_hp run data get entity @s Health 1000
scoreboard players set @e[tag=zx.burial_new,distance=0..,limit=1] zx.burial_abs 0
execute if data entity @s AbsorptionAmount store result score @e[tag=zx.burial_new,distance=0..,limit=1] zx.burial_abs run data get entity @s AbsorptionAmount 1000
tag @e[tag=zx.burial_new,distance=0..] remove zx.burial_new
