execute unless score @s zx.ec_badd matches 1.. run return 0
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
scoreboard players set #ec_back zx.meta 0
scoreboard players operation #ec_back zx.meta -= @s zx.ec_badd
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #ec_back zx.meta
function manacore:api/stats/add
scoreboard players set @s zx.ec_badd 0
