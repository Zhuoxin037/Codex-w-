data modify storage manacore:in arg set value {uuid:"",key:"max_health",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #s2_diff zx.meta
function manacore:api/stats/add
execute if score @s zx.s2_hp matches 1.. run attribute @s minecraft:max_health modifier remove fallendream:batch21_hp
scoreboard players operation @s zx.s2_hp = #s2_want_hp zx.meta
execute store result storage zx:work s2_stat.value int 1 run scoreboard players get @s zx.s2_hp
execute if score @s zx.s2_hp matches 1.. run function fallendream:batch21/native_hp with storage zx:work s2_stat
