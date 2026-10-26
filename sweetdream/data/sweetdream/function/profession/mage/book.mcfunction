scoreboard players remove @s zx.j_orb 1
scoreboard players operation @s zx.j_book_t = #now manacore.meta
execute unless score @s zx.j_pay_t = #now manacore.meta run return 0
scoreboard players operation #jrefund zx.meta = @s zx.j_paid
scoreboard players operation #jrefund zx.meta /= #j5 zx.meta
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #jrefund zx.meta
function manacore:api/mana/add
