execute unless score @s zx.job matches 4 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 4 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:empathy",mana:250.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:250.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:empathy",cooldown_seconds:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
execute store result score #jem_self zx.meta run data get entity @s Health 1000
scoreboard players operation #jem_self zx.meta /= #j2 zx.meta
execute store result storage zx:work jem.amount double .001 run scoreboard players get #jem_self zx.meta
function sweetdream:profession/berserker/self_damage with storage zx:work jem
scoreboard players set @s zx.j_empath 240

scoreboard players operation @s zx.j_em_end = #now manacore.meta
scoreboard players add @s zx.j_em_end 240
