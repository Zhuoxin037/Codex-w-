data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #s2_diff zx.meta
function manacore:api/stats/add
execute if score @s zx.s2_atk matches 1.. run attribute @s minecraft:attack_damage modifier remove sweetdream:batch21_atk
scoreboard players operation @s zx.s2_atk = #s2_want_atk zx.meta
execute store result storage zx:work s2_stat.value int 1 run scoreboard players get @s zx.s2_atk
execute if score @s zx.s2_atk matches 1.. run function sweetdream:batch21/native_atk with storage zx:work s2_stat
