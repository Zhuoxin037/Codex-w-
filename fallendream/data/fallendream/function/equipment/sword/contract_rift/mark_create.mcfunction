execute store result storage zx:work cr.t0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work cr.t1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work cr.t2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work cr.t3 int 1 run data get entity @s UUID[3]
scoreboard players operation #cr_count zx.meta = @s zx.j_ess
scoreboard players set @s zx.j_ess 0
summon minecraft:marker ~ ~ ~ {Tags:["zx.cr_mark","zx.cr_new"],data:{}}
data modify entity @e[tag=zx.cr_new,distance=0..,limit=1] data set from storage zx:work cr
scoreboard players operation @e[tag=zx.cr_new,distance=0..,limit=1] zx.cr_layers = #cr_count zx.meta
scoreboard players operation @e[tag=zx.cr_new,distance=0..,limit=1] zx.cr_until = #now manacore.meta
scoreboard players add @e[tag=zx.cr_new,distance=0..,limit=1] zx.cr_until 240
tag @e[tag=zx.cr_new,distance=0..] remove zx.cr_new
