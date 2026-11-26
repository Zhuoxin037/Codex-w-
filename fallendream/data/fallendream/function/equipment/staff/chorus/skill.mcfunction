execute unless score @s zx.job matches 3 run return fail
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work chorus set value {uuid:""}
data modify storage zx:work chorus.uuid set from storage zx:data self.uuid
function fallendream:equipment/staff/chorus/count with storage zx:work chorus
execute unless score #chorus_n zx.meta matches 1..3 run return fail
scoreboard players operation #chorus_cost zx.meta = #chorus_n zx.meta
scoreboard players set #chorus_ninety zx.meta 90
scoreboard players operation #chorus_cost zx.meta *= #chorus_ninety zx.meta
scoreboard players add #chorus_cost zx.meta 150
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:chorus",mana:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.mana double 1 run scoreboard players get #chorus_cost zx.meta
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #chorus_cost zx.meta
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:chorus",cooldown_seconds:65.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
summon minecraft:marker ~ ~ ~ {Tags:["zx.cs_conductor","zx.cs_new"],data:{owner:"",u0:0,u1:0,u2:0,u3:0}}
data modify entity @e[tag=zx.cs_new,distance=0..,limit=1] data.owner set from storage zx:data self.uuid
execute store result entity @e[tag=zx.cs_new,distance=0..,limit=1] data.u0 int 1 run scoreboard players get @s manacore.u0
execute store result entity @e[tag=zx.cs_new,distance=0..,limit=1] data.u1 int 1 run scoreboard players get @s manacore.u1
execute store result entity @e[tag=zx.cs_new,distance=0..,limit=1] data.u2 int 1 run scoreboard players get @s manacore.u2
execute store result entity @e[tag=zx.cs_new,distance=0..,limit=1] data.u3 int 1 run scoreboard players get @s manacore.u3
scoreboard players set @e[tag=zx.cs_new,distance=0..,limit=1] zx.cs_left 240
data modify storage zx:work chorus set value {uuid:"",c0:0,c1:0,c2:0,c3:0}
data modify storage zx:work chorus.uuid set from storage zx:data self.uuid
data modify storage zx:work chorus.c0 set from entity @e[tag=zx.cs_new,distance=0..,limit=1] UUID[0]
data modify storage zx:work chorus.c1 set from entity @e[tag=zx.cs_new,distance=0..,limit=1] UUID[1]
data modify storage zx:work chorus.c2 set from entity @e[tag=zx.cs_new,distance=0..,limit=1] UUID[2]
data modify storage zx:work chorus.c3 set from entity @e[tag=zx.cs_new,distance=0..,limit=1] UUID[3]
data modify entity @e[tag=zx.cs_new,distance=0..,limit=1] data.c0 set from storage zx:work chorus.c0
data modify entity @e[tag=zx.cs_new,distance=0..,limit=1] data.c1 set from storage zx:work chorus.c1
data modify entity @e[tag=zx.cs_new,distance=0..,limit=1] data.c2 set from storage zx:work chorus.c2
data modify entity @e[tag=zx.cs_new,distance=0..,limit=1] data.c3 set from storage zx:work chorus.c3
tag @e[tag=zx.cs_new,distance=0..] remove zx.cs_new
function fallendream:equipment/staff/chorus/convert with storage zx:work chorus
