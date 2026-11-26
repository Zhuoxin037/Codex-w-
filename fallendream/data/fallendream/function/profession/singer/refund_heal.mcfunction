# 使用与 lib/heal 相同的限幅和跨刻卸载方式；这里保留千分之一生命精度。
execute store result score #jf_hp zx.meta run data get entity @s Health 1000
execute store result score #jf_cap zx.meta run attribute @s minecraft:max_health get 1000
scoreboard players operation #jf_base zx.meta = #jf_hp zx.meta
execute if entity @s[tag=zx.heal_p] if score #jf_cap zx.meta > #jf_base zx.meta run scoreboard players operation #jf_base zx.meta = #jf_cap zx.meta
execute if entity @s[tag=zx.heal_on] if score #jf_cap zx.meta > #jf_base zx.meta run scoreboard players operation #jf_base zx.meta = #jf_cap zx.meta
execute if entity @s[tag=zx.heal_p] run attribute @s minecraft:max_health modifier remove fallendream:heal_cap
execute if entity @s[tag=zx.heal_on] run attribute @s minecraft:max_health modifier remove fallendream:heal_cap
tag @s remove zx.heal_p
tag @s remove zx.heal_on
execute store result score #jf_cap zx.meta run attribute @s minecraft:max_health get 1000
scoreboard players operation #jf_amt zx.meta = #jf_cap zx.meta
scoreboard players set #jf_fifty zx.meta 50
scoreboard players operation #jf_amt zx.meta /= #jf_fifty zx.meta
scoreboard players operation #jf_amt zx.meta *= #j_duet_refund zx.meta
scoreboard players operation #jf_new zx.meta = #jf_base zx.meta
scoreboard players operation #jf_new zx.meta += #jf_amt zx.meta
execute if score #jf_new zx.meta > #jf_cap zx.meta run scoreboard players operation #jf_new zx.meta = #jf_cap zx.meta
scoreboard players operation #jf_diff zx.meta = #jf_new zx.meta
scoreboard players operation #jf_diff zx.meta -= #jf_cap zx.meta
data modify storage zx:work hp set value {d:0.0}
execute store result storage zx:work hp.d double 0.001 run scoreboard players get #jf_diff zx.meta
function fallendream:lib/heal_up with storage zx:work hp
