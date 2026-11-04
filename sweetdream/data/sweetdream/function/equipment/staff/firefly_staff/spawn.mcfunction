scoreboard players set #ff_n zx.meta 0
$execute store result score #ff_n zx.meta if entity @e[tag=zx.ff_particle,distance=0..,nbt={data:{owner:"$(uuid)"}}]
execute if score #ff_n zx.meta matches 10.. run return 0
summon minecraft:marker ~ ~1 ~ {Tags:["zx.ff_particle","zx.ff_idle","zx.ff_new"],data:{angle:0,u0:0,u1:0,u2:0,u3:0}}
$data modify entity @e[tag=zx.ff_new,distance=0..,limit=1] data.owner set value "$(uuid)"
execute store result entity @e[tag=zx.ff_new,distance=0..,limit=1] data.u0 int 1 run scoreboard players get @s manacore.u0
execute store result entity @e[tag=zx.ff_new,distance=0..,limit=1] data.u1 int 1 run scoreboard players get @s manacore.u1
execute store result entity @e[tag=zx.ff_new,distance=0..,limit=1] data.u2 int 1 run scoreboard players get @s manacore.u2
execute store result entity @e[tag=zx.ff_new,distance=0..,limit=1] data.u3 int 1 run scoreboard players get @s manacore.u3
scoreboard players set #ff_angle zx.meta 36
scoreboard players operation #ff_n zx.meta *= #ff_angle zx.meta
execute store result entity @e[tag=zx.ff_new,distance=0..,limit=1] data.angle int 1 run scoreboard players get #ff_n zx.meta
tag @e[tag=zx.ff_new,distance=0..] remove zx.ff_new
