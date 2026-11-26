# 本入口由共享受伤事件串行分发，hurt_evt已换算为实际毫生命损失。
advancement revoke @s only fallendream:equipment/armor/bulwark_hurt
execute if entity @s[tag=zx.bw_self] run return 0
execute unless items entity @s armor.chest *[custom_data~{zx:["bulwark"]}] run return 0
function fallendream:lib/hp_pct
execute if score #hp_p100 zx.meta matches ..999 run effect give @s minecraft:instant_health 1 4 true
execute if score #hp_p100 zx.meta matches ..999 run return 0
scoreboard players operation #mp_src zx.meta = @s zx.hurt_evt
scoreboard players set #mp_mul zx.meta 200
function fallendream:lib/math/mul_permille
scoreboard players operation #bw_x zx.meta = #mp_out zx.meta
scoreboard players operation #bw_cap zx.meta = #max_hp zx.meta
scoreboard players operation #bw_cap zx.meta /= #5 zx.meta
execute if score #bw_x zx.meta > #bw_cap zx.meta run scoreboard players operation #bw_x zx.meta = #bw_cap zx.meta
execute unless score #bw_x zx.meta matches 1.. run return 0
execute store result score #bw_before zx.meta run data get entity @s Health 1000
execute store result storage zx:work bw.v double 0.001 run scoreboard players get #bw_x zx.meta
tag @s add zx.bw_self
function fallendream:equipment/armor/bulwark/self_hurt with storage zx:work bw
tag @s remove zx.bw_self
scoreboard players set #bw_after zx.meta 0
execute store result score #bw_after zx.meta run data get entity @s Health 1000
scoreboard players operation #bw_x zx.meta = #bw_before zx.meta
scoreboard players operation #bw_x zx.meta -= #bw_after zx.meta
execute if score #bw_x zx.meta matches 1.. run function fallendream:equipment/armor/bulwark/boost
scoreboard players operation @s zx.bw_hp = #bw_after zx.meta
