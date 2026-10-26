execute unless score @s zx.job matches 1 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 1 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:mana_crystal",mana:250.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:250.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:mana_crystal",cooldown_seconds:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
data modify storage manacore:in arg set value {uuid:"",id:"job_mana_crystal",type:"sweetdream:mana_crystal",duration_seconds:10.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create
scoreboard players set @s zx.j_cr_t 200
scoreboard players set @s zx.j_cr_n 0
scoreboard players set @s zx.j_cr_d 5

scoreboard players set @s zx.j_cr_book 0
scoreboard players set @s zx.j_cr_sor 0
execute if score @s zx.j_book_t = #now manacore.meta run scoreboard players set @s zx.j_cr_book 1
execute if score @s zx.j_sor_t = #now manacore.meta run scoreboard players set @s zx.j_cr_sor 1

scoreboard players operation @s zx.j_cr_end = #now manacore.meta
scoreboard players add @s zx.j_cr_end 200
