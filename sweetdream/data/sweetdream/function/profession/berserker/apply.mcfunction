function sweetdream:profession/berserker/expire
scoreboard players add @s zx.j_b_sum 0
scoreboard players operation #jbdiff zx.meta = #jbsum zx.meta
scoreboard players operation #jbdiff zx.meta -= @s zx.j_b_sum
execute if score #jbdiff zx.meta matches 0 run return 0
function sweetdream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #jbdiff zx.meta
function manacore:api/stats/add
scoreboard players operation @s zx.j_b_sum = #jbsum zx.meta
attribute @s minecraft:attack_damage modifier remove sweetdream:profession_berserker
execute store result storage zx:work jbattr.value double 0.001 run scoreboard players get #jbsum zx.meta
execute if score #jbsum zx.meta matches 1.. run function sweetdream:profession/berserker/native with storage zx:work jbattr
