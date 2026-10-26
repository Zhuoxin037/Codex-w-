execute unless entity @s[type=minecraft:player,scores={zx.job=3}] run return 0
data modify storage zx:work jf_event set value {out:{},in:{},self:{}}
data modify storage zx:work jf_event.out set from storage manacore:out r
data modify storage zx:work jf_event.in set from storage manacore:in arg
data modify storage zx:work jf_event.self set from storage zx:data self
function sweetdream:lib/uuid
summon minecraft:marker ~ ~ ~ {Tags:["zx.j_follower","zx.j_f_new"],data:{u0:0,u1:0,u2:0,u3:0}}
execute store result entity @e[tag=zx.j_f_new,limit=1] data.u0 int 1 run scoreboard players get @s manacore.u0
execute store result entity @e[tag=zx.j_f_new,limit=1] data.u1 int 1 run scoreboard players get @s manacore.u1
execute store result entity @e[tag=zx.j_f_new,limit=1] data.u2 int 1 run scoreboard players get @s manacore.u2
execute store result entity @e[tag=zx.j_f_new,limit=1] data.u3 int 1 run scoreboard players get @s manacore.u3
data modify entity @e[tag=zx.j_f_new,limit=1] data.owner set from storage zx:data self.uuid
scoreboard players set @e[tag=zx.j_f_new,limit=1] zx.j_life 200
tag @e[tag=zx.j_f_new] remove zx.j_f_new
data modify storage manacore:out r set from storage zx:work jf_event.out
data modify storage manacore:in arg set from storage zx:work jf_event.in
data modify storage zx:data self set from storage zx:work jf_event.self
