execute unless score @s zx.job matches 4 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 4 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
execute if score @s zx.j_form matches 0 if score @s zx.j_reborn matches 1.. run tellraw @s {"text":"同生体尚未再生。","color":"red"}
execute if score @s zx.j_form matches 0 if score @s zx.j_reborn matches 1.. run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:self_mind",mana:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:self_mind",cooldown_seconds:8.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
scoreboard players set #jwasform zx.meta 0
execute if score @s zx.j_form matches 1 run scoreboard players set #jwasform zx.meta 1
execute if score #jwasform zx.meta matches 1 run function sweetdream:profession/twin/return
execute if score #jwasform zx.meta matches 0 run function sweetdream:profession/twin/enter
execute if score #jwasform zx.meta matches 1 run function sweetdream:profession/twin/return_bonus
execute if score #jwasform zx.meta matches 0 run function sweetdream:profession/twin/enter_bonus
