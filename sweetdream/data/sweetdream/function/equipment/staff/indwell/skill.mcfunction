execute unless score @s zx.job matches 4 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 4 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
execute unless score @s zx.j_form matches 0 run tellraw @s {"text":"寄宿仅在本我者状态可用。","color":"red"}
execute unless score @s zx.j_form matches 0 run return fail
execute if score @s zx.j_reborn matches 1.. run tellraw @s {"text":"同生体尚未再生，无法寄宿。","color":"red"}
execute if score @s zx.j_reborn matches 1.. run return fail
execute if score @s zx.j_pick matches 2 run return run function sweetdream:profession/twin/host_confirm
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:indwell",mana:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:indwell",cooldown_seconds:100.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
data modify storage manacore:in arg set value {uuid:"",id:"job_indwell",type:"sweetdream:indwell",duration_seconds:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create
scoreboard players set @s zx.j_pick 2
tellraw @s {"text":"瞄准 12 格内具有「本质」的生物，再次潜行使用寄宿确认。","color":"aqua"}
