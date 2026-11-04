execute store result storage zx:work burial_snapshot.t0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work burial_snapshot.t1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work burial_snapshot.t2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work burial_snapshot.t3 int 1 run data get entity @s UUID[3]
summon minecraft:marker ~ ~ ~ {Tags:["zx.burial_delay","zx.burial_new"],data:{}}
data modify entity @e[tag=zx.burial_new,distance=0..,limit=1] data set from storage zx:work burial_snapshot
scoreboard players operation @e[tag=zx.burial_new,distance=0..,limit=1] zx.burial_end = #now manacore.meta
scoreboard players add @e[tag=zx.burial_new,distance=0..,limit=1] zx.burial_end 10
tag @e[tag=zx.burial_new,distance=0..] remove zx.burial_new
