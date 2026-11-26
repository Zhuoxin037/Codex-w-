execute store result storage zx:work wst.t0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work wst.t1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work wst.t2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work wst.t3 int 1 run data get entity @s UUID[3]
summon minecraft:marker ~ ~ ~ {Tags:["zx.ws_delay","zx.ws_new"],data:{}}
data modify entity @e[tag=zx.ws_new,distance=0..,limit=1] data set from storage zx:work wst
scoreboard players operation @e[tag=zx.ws_new,distance=0..,limit=1] zx.ws_due = #now manacore.meta
scoreboard players add @e[tag=zx.ws_new,distance=0..,limit=1] zx.ws_due 10
tag @e[tag=zx.ws_new,distance=0..] remove zx.ws_new
