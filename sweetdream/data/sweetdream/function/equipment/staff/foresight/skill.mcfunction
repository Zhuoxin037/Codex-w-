execute unless score @s zx.job matches 1 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 1 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
execute unless score @s zx.j_prop matches 1.. run tellraw @s {"text":"没有可消耗的「预言」。","color":"red"}
execute unless score @s zx.j_prop matches 1.. run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:foresight",mana:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:foresight",cooldown_seconds:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
scoreboard players operation @s zx.j_draws = @s zx.j_prop
scoreboard players set @s zx.j_prop 0
scoreboard players set @s zx.j_seen 0
scoreboard players set @s zx.j_grace 0
function sweetdream:profession/mage/draw

scoreboard players set @s zx.j_fs_book 0
scoreboard players set @s zx.j_fs_sor 0
execute if score @s zx.j_book_t = #now manacore.meta run scoreboard players set @s zx.j_fs_book 1
execute if score @s zx.j_sor_t = #now manacore.meta run scoreboard players set @s zx.j_fs_sor 1
