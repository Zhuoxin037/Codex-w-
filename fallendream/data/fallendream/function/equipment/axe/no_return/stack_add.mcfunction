function fallendream:lib/uuid
summon minecraft:marker ~ ~ ~ {Tags:["zx.nr_bonus","zx.nr_new"],data:{owner:"",u0:0,u1:0,u2:0,u3:0}}
data modify entity @e[tag=zx.nr_new,distance=0..,limit=1] data.owner set from storage zx:data self.uuid
execute store result entity @e[tag=zx.nr_new,distance=0..,limit=1] data.u0 int 1 run scoreboard players get @s manacore.u0
execute store result entity @e[tag=zx.nr_new,distance=0..,limit=1] data.u1 int 1 run scoreboard players get @s manacore.u1
execute store result entity @e[tag=zx.nr_new,distance=0..,limit=1] data.u2 int 1 run scoreboard players get @s manacore.u2
execute store result entity @e[tag=zx.nr_new,distance=0..,limit=1] data.u3 int 1 run scoreboard players get @s manacore.u3
scoreboard players operation @e[tag=zx.nr_new,distance=0..,limit=1] zx.nr_val = #jbbonus zx.meta
scoreboard players operation @e[tag=zx.nr_new,distance=0..,limit=1] zx.nr_gen = @s zx.nr_gen
scoreboard players operation @e[tag=zx.nr_new,distance=0..,limit=1] zx.nr_due = #now manacore.meta
scoreboard players add @e[tag=zx.nr_new,distance=0..,limit=1] zx.nr_due 160
scoreboard players add @s zx.nr_extra 0
scoreboard players operation @s zx.nr_extra += #jbbonus zx.meta
tag @e[tag=zx.nr_new,distance=0..] remove zx.nr_new
