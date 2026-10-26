execute unless score @s zx.job matches 1 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 1 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:mana_imbue",mana:180.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:180.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:mana_imbue",cooldown_seconds:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
scoreboard players operation @s zx.j_im_n = @s zx.j_orb
scoreboard players set @s zx.j_orb 0
