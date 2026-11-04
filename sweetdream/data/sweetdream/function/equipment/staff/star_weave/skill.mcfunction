function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:star_weave",mana:240.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:240.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:star_weave",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
function sweetdream:lib/uuid
scoreboard players add @s zx.j_orb 0
scoreboard players operation #weave_pulses zx.meta = @s zx.j_orb
scoreboard players set @s zx.j_orb 0
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:star_weave",type:"star_weave",duration_seconds:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #weave_pulses zx.meta matches 1.. store result storage manacore:in arg.duration_seconds double 1 run scoreboard players get #weave_pulses zx.meta
function manacore:api/formation/create
summon minecraft:marker ~ ~ ~ {Tags:["zx.weave_field","zx.weave_new"],data:{owner:"",u0:0,u1:0,u2:0,u3:0,c0:0,c1:0,c2:0,c3:0}}
data modify entity @e[tag=zx.weave_new,distance=0..,limit=1] data.owner set from storage zx:data self.uuid
execute store result entity @e[tag=zx.weave_new,distance=0..,limit=1] data.u0 int 1 run scoreboard players get @s manacore.u0
execute store result entity @e[tag=zx.weave_new,distance=0..,limit=1] data.u1 int 1 run scoreboard players get @s manacore.u1
execute store result entity @e[tag=zx.weave_new,distance=0..,limit=1] data.u2 int 1 run scoreboard players get @s manacore.u2
execute store result entity @e[tag=zx.weave_new,distance=0..,limit=1] data.u3 int 1 run scoreboard players get @s manacore.u3
scoreboard players operation @e[tag=zx.weave_new,distance=0..,limit=1] zx.weave_left = #weave_pulses zx.meta
scoreboard players set @e[tag=zx.weave_new,distance=0..,limit=1] zx.weave_clock 20
scoreboard players set @e[tag=zx.weave_new,distance=0..,limit=1] zx.weave_round 0
data modify storage zx:work weavefield set from entity @e[tag=zx.weave_new,distance=0..,limit=1] data
data modify storage zx:work weavefield.c0 set from entity @e[tag=zx.weave_new,distance=0..,limit=1] UUID[0]
data modify storage zx:work weavefield.c1 set from entity @e[tag=zx.weave_new,distance=0..,limit=1] UUID[1]
data modify storage zx:work weavefield.c2 set from entity @e[tag=zx.weave_new,distance=0..,limit=1] UUID[2]
data modify storage zx:work weavefield.c3 set from entity @e[tag=zx.weave_new,distance=0..,limit=1] UUID[3]
data modify entity @e[tag=zx.weave_new,distance=0..,limit=1] data set from storage zx:work weavefield
tag @e[tag=zx.weave_new,distance=0..] remove zx.weave_new
scoreboard players set #weave_index zx.meta 0
function sweetdream:equipment/staff/star_weave/convert with storage zx:work weavefield
function sweetdream:equipment/staff/star_weave/set_count with storage zx:work weavefield
