advancement revoke @s only sweetdream:equipment/bow/lianshi
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work shot set value {id:"lianshi",paid:0b,channel_atk:0.0,damage:0.0,u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work shot.u0 set from entity @s UUID[0]
data modify storage zx:work shot.u1 set from entity @s UUID[1]
data modify storage zx:work shot.u2 set from entity @s UUID[2]
data modify storage zx:work shot.u3 set from entity @s UUID[3]
data modify storage manacore:in arg set value {uuid:"",value:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:1b} run data modify storage zx:work shot.paid set value 1b
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #shot_d zx.meta run data get storage manacore:out r.value 1000
scoreboard players set #shot_cap zx.meta 2147483647
scoreboard players operation #shot_cap zx.meta /= #15 zx.meta
execute if score #shot_d zx.meta > #shot_cap zx.meta run scoreboard players operation #shot_d zx.meta = #shot_cap zx.meta
scoreboard players operation #shot_d zx.meta *= #15 zx.meta
scoreboard players operation #shot_d zx.meta /= #100 zx.meta
execute store result storage zx:work shot.damage double 0.001 run scoreboard players get #shot_d zx.meta
tag @s add zx.shot_owner
execute as @e[type=#sweetdream:cc_arrow,tag=!zx.review_bound,distance=..16,nbt={HasBeenShot:0b}] run function sweetdream:internal/bow/bind
tag @s remove zx.shot_owner
function sweetdream:equipment/staff/apocalypse/spend
