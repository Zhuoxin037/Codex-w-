advancement revoke @s only sweetdream:equipment/bow/night_bind
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work shot set value {id:"night_bind",paid:0b,channel_atk:5.0,damage:0.0,u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work shot.u0 set from entity @s UUID[0]
data modify storage zx:work shot.u1 set from entity @s UUID[1]
data modify storage zx:work shot.u2 set from entity @s UUID[2]
data modify storage zx:work shot.u3 set from entity @s UUID[3]
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:1b} run data modify storage zx:work shot.paid set value 1b
data modify storage manacore:in arg set value {uuid:"",attack_mul:5.0,independent_multiplier:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work shot.damage set from storage manacore:out r.damage
tag @s add zx.shot_owner
execute as @e[type=#sweetdream:cc_arrow,tag=!zx.review_bound,distance=..16,nbt={HasBeenShot:0b}] run function sweetdream:internal/bow/bind
tag @s remove zx.shot_owner
function sweetdream:equipment/staff/apocalypse/spend
