data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #s2_diff zx.meta
function manacore:api/mana/max/add
scoreboard players operation @s zx.s2_mana = #s2_want_mana zx.meta
