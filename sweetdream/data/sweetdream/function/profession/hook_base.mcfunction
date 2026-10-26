# @calc: add
execute unless entity @s[type=minecraft:player] run return 0
scoreboard players set #jmul_m zx.meta 1000
scoreboard players set #jmul_a zx.meta 1000
scoreboard players set #jmul_o zx.meta 1000
scoreboard players set #jmul_x zx.meta 1000
execute if score @s zx.job matches 1 run scoreboard players set #jmul_m zx.meta 1500
execute if score @s zx.job matches 1 run scoreboard players set #jmul_a zx.meta 600
execute if score @s zx.job matches 2 run scoreboard players set #jmul_m zx.meta 600
execute if score @s zx.job matches 2 run scoreboard players set #jmul_a zx.meta 1500
execute if score @s zx.job matches 3 run scoreboard players set #jmul_m zx.meta 800
execute if score @s zx.job matches 3 run scoreboard players set #jmul_a zx.meta 800
execute if score @s zx.job matches 3 run scoreboard players set #jmul_o zx.meta 800
execute if score @s zx.job matches 3 run scoreboard players set #jmul_x zx.meta 800
execute if score @s zx.job matches 4 run scoreboard players set #jmul_m zx.meta 700
execute if score @s zx.job matches 4 run scoreboard players set #jmul_a zx.meta 1300
execute if score @s zx.job matches 4 if score @s zx.j_form matches 1 run scoreboard players set #jmul_m zx.meta 1100
execute if score @s zx.job matches 4 if score @s zx.j_form matches 1 run scoreboard players set #jmul_a zx.meta 1100
execute if score @s zx.job matches 4 if score @s zx.j_form matches 1 run scoreboard players set #jmul_o zx.meta 1100
execute if score @s zx.job matches 4 if score @s zx.j_form matches 1 run scoreboard players set #jmul_x zx.meta 1100
scoreboard players set #mp_src zx.meta 0
execute store result score #mp_src zx.meta run data get storage manacore:out r.seg_m
scoreboard players operation #mp_mul zx.meta = #jmul_m zx.meta
function sweetdream:lib/math/mul_permille
execute store result storage manacore:out r.seg_m int 1 run scoreboard players get #mp_out zx.meta
scoreboard players set #mp_src zx.meta 0
execute store result score #mp_src zx.meta run data get storage manacore:out r.seg_a
scoreboard players operation #mp_mul zx.meta = #jmul_a zx.meta
function sweetdream:lib/math/mul_permille
execute store result storage manacore:out r.seg_a int 1 run scoreboard players get #mp_out zx.meta
scoreboard players set #mp_src zx.meta 0
execute store result score #mp_src zx.meta run data get storage manacore:out r.seg_o
scoreboard players operation #mp_mul zx.meta = #jmul_o zx.meta
function sweetdream:lib/math/mul_permille
execute store result storage manacore:out r.seg_o int 1 run scoreboard players get #mp_out zx.meta
scoreboard players set #mp_src zx.meta 0
execute store result score #mp_src zx.meta run data get storage manacore:out r.seg_x
scoreboard players operation #mp_mul zx.meta = #jmul_x zx.meta
function sweetdream:lib/math/mul_permille
execute store result storage manacore:out r.seg_x int 1 run scoreboard players get #mp_out zx.meta

execute if score @s zx.job matches 1 if score @s zx.j_aw matches 1 run function sweetdream:profession/mage/awake_add
# Rebuild the unboosted total so the existing empty-additive-pool fast path stays correct.
scoreboard players set #jtot zx.meta 0
execute store result score #jpart zx.meta run data get storage manacore:out r.seg_m
scoreboard players operation #jtot zx.meta += #jpart zx.meta
execute store result score #jpart zx.meta run data get storage manacore:out r.seg_a
scoreboard players operation #jtot zx.meta += #jpart zx.meta
execute store result score #jpart zx.meta run data get storage manacore:out r.seg_o
scoreboard players operation #jtot zx.meta += #jpart zx.meta
execute store result score #jpart zx.meta run data get storage manacore:out r.seg_x
scoreboard players operation #jtot zx.meta += #jpart zx.meta
execute store result score #jim zx.meta run data get storage manacore:out r.im
function manacore:internal/damage/mul_pct {src:"#jtot",mul:"#jim",obj:"zx.meta"}
execute if score #mul_out zx.meta matches ..0 run scoreboard players set #mul_out zx.meta 0
execute store result storage manacore:out r.damage double 0.001 run scoreboard players get #mul_out zx.meta
execute if score @s zx.job matches 1 if items entity @s armor.head *[custom_data~{zx:["eagle_hat"]}] run function sweetdream:profession/mage/hat_calc
