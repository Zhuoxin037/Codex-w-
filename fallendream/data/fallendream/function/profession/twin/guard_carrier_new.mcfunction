execute at @e[tag=zx.j_anchor,limit=1] run summon minecraft:armor_stand ~ ~ ~ {Tags:["zx.j_guard_carrier","zx.j_gc_new"],Marker:1b,Invisible:1b,NoGravity:1b,Invulnerable:1b}
data modify entity @e[tag=zx.j_gc_new,limit=1] data set value {owner:"",u0:0,u1:0,u2:0,u3:0}
data modify entity @e[tag=zx.j_gc_new,limit=1] data.owner set from storage zx:data self.uuid
execute store result entity @e[tag=zx.j_gc_new,limit=1] data.u0 int 1 run scoreboard players get @s manacore.u0
execute store result entity @e[tag=zx.j_gc_new,limit=1] data.u1 int 1 run scoreboard players get @s manacore.u1
execute store result entity @e[tag=zx.j_gc_new,limit=1] data.u2 int 1 run scoreboard players get @s manacore.u2
execute store result entity @e[tag=zx.j_gc_new,limit=1] data.u3 int 1 run scoreboard players get @s manacore.u3
tag @e[tag=zx.j_gc_new] remove zx.j_gc_new
