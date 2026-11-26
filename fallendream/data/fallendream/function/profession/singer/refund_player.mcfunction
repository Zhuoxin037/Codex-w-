function fallendream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",value:50.0}
scoreboard players operation #j_duet_mana zx.meta = #j_duet_refund zx.meta
scoreboard players set #j_duet_ten zx.meta 10
scoreboard players operation #j_duet_mana zx.meta *= #j_duet_ten zx.meta
scoreboard players add #j_duet_mana zx.meta 50
execute store result storage manacore:in arg.value double 1 run scoreboard players get #j_duet_mana zx.meta
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add
execute if score #j_duet_refund zx.meta matches 1.. run function fallendream:profession/singer/refund_heal
