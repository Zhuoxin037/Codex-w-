execute store result storage zx:work jdelay.t0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work jdelay.t1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work jdelay.t2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work jdelay.t3 int 1 run data get entity @s UUID[3]
summon minecraft:marker ~ ~ ~ {Tags:["zx.j_delayed","zx.j_delayed_new"],data:{}}
data modify entity @e[tag=zx.j_delayed_new,limit=1] data set from storage zx:work jdelay
scoreboard players set @e[tag=zx.j_delayed_new,limit=1] zx.j_pulse 10
execute store result score @e[tag=zx.j_delayed_new,limit=1] zx.j_life run data get storage zx:work jdelay.count
tag @e[tag=zx.j_delayed_new] remove zx.j_delayed_new
