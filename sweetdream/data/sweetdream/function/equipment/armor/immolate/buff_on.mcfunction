data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:100.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/add
scoreboard players set @s zx.im_buff_mk 100
scoreboard players set @s zx.im_buff 20
execute at @s run particle minecraft:flame ~ ~1 ~ 0.6 0.8 0.6 0.02 20 normal
execute at @s run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.8 0.9