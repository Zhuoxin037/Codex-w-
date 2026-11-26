function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:exalted",mana:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:exalted",cooldown_seconds:100.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
data modify storage manacore:in arg set value {uuid:"",id:"fallendream:exalted",type:"graveyard",duration_seconds:16.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create
summon minecraft:marker ~ ~ ~ {Tags:["zx.ex_grave","zx.ex_new"],data:{owner:"",u0:0,u1:0,u2:0,u3:0}}
data modify entity @e[tag=zx.ex_new,distance=0..,limit=1] data.owner set from storage zx:data self.uuid
execute store result entity @e[tag=zx.ex_new,distance=0..,limit=1] data.u0 int 1 run scoreboard players get @s manacore.u0
execute store result entity @e[tag=zx.ex_new,distance=0..,limit=1] data.u1 int 1 run scoreboard players get @s manacore.u1
execute store result entity @e[tag=zx.ex_new,distance=0..,limit=1] data.u2 int 1 run scoreboard players get @s manacore.u2
execute store result entity @e[tag=zx.ex_new,distance=0..,limit=1] data.u3 int 1 run scoreboard players get @s manacore.u3
scoreboard players operation @e[tag=zx.ex_new,distance=0..,limit=1] zx.ex_until = #now manacore.meta
scoreboard players add @e[tag=zx.ex_new,distance=0..,limit=1] zx.ex_until 320
tag @e[tag=zx.ex_new,distance=0..] remove zx.ex_new
