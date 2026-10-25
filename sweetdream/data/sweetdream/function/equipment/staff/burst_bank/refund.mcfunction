# 快照bb.uuid属于本次施放者；把bb_paid清零保证异常回退只退款一次。
execute unless score @s zx.bb_paid matches 1.. run return 0
scoreboard players operation #bb_r zx.meta = @s zx.bb_paid
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:work bb.uuid
execute store result storage manacore:in arg.value double 0.5 run scoreboard players get #bb_r zx.meta
function manacore:api/mana/add
scoreboard players set @s zx.bb_paid 0
tellraw @s [{"text":"落点无法站立，决堤改为原地施放并返还一半消耗的魔力","color":"yellow"}]
