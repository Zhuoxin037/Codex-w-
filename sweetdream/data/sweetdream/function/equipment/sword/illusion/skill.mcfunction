execute unless score @s zx.job matches 4 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 4 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:illusion",mana:400.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:400.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:illusion",cooldown_seconds:50.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
data modify storage manacore:in arg set value {uuid:"",id:"job_illusion",type:"sweetdream:illusion",duration_seconds:12.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create
scoreboard players set @s zx.j_il_t 240

scoreboard players set @s zx.j_il_book 0
scoreboard players set @s zx.j_il_sor 0
execute if score @s zx.j_book_t = #now manacore.meta run scoreboard players set @s zx.j_il_book 1
execute if score @s zx.j_sor_t = #now manacore.meta run scoreboard players set @s zx.j_il_sor 1

scoreboard players operation @s zx.j_il_end = #now manacore.meta
scoreboard players add @s zx.j_il_end 240
