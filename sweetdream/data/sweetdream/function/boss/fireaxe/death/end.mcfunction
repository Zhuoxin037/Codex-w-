function sweetdream:boss/fireaxe/ash/burst_3
summon minecraft:marker ~ ~ ~ {Tags:["sd.fb.ash_cloud","sd.fb.ash_cloud_new"]}
scoreboard players set @e[tag=sd.fb.ash_cloud_new,distance=..0.01,limit=1] sdbf.death_age 0
tag @e[tag=sd.fb.ash_cloud_new,distance=0..] remove sd.fb.ash_cloud_new
function sweetdream:boss/fireaxe/remove_rig
