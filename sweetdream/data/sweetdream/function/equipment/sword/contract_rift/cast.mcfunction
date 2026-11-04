advancement revoke @s only sweetdream:equipment/sword/contract_rift
execute unless score @s zx.job matches 4 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 4 run return fail
tag @e[tag=zx.cr_pick] remove zx.cr_pick
scoreboard players set #cr_steps zx.meta 0
execute anchored eyes run function sweetdream:equipment/sword/contract_rift/ray
execute unless entity @e[tag=zx.cr_pick,distance=0..,limit=1] run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:contract_rift",mana:160.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:160.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:contract_rift",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
scoreboard players add @s zx.hurt_total 0
scoreboard players operation @s zx.cr_seen = @s zx.hurt_total
scoreboard players operation @s zx.cr_total = @s zx.hurt_total
scoreboard players operation @s zx.cr_done = @s zx.hurt_total
execute store result score @s zx.cr_hp run data get entity @s Health 1000
data modify storage zx:work cr set value {owner:"",u0:0,u1:0,u2:0,u3:0,t0:0,t1:0,t2:0,t3:0,cap:5}
data modify storage zx:work cr.owner set from storage zx:data self.uuid
execute store result storage zx:work cr.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work cr.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work cr.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work cr.u3 int 1 run scoreboard players get @s manacore.u3
execute if score @s zx.j_aw matches 1 run data modify storage zx:work cr.cap set value 8
execute as @e[tag=zx.cr_pick,distance=0..,limit=1] at @s run function sweetdream:equipment/sword/contract_rift/mark_create
function sweetdream:equipment/sword/contract_rift/clear_owner_body with storage zx:work cr
tag @e[tag=zx.cr_pick,distance=0..] remove zx.cr_pick
