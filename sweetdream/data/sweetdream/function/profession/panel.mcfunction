# @panel: smul_mm,smul_atk,smul_oth
scoreboard players set #jpanelm zx.meta 1000
scoreboard players set #jpanela zx.meta 1000
scoreboard players set #jpanelo zx.meta 1000
execute if score @s zx.job matches 1 run scoreboard players set #jpanelm zx.meta 1500
execute if score @s zx.job matches 1 run scoreboard players set #jpanela zx.meta 600
execute if score @s zx.job matches 2 run scoreboard players set #jpanelm zx.meta 600
execute if score @s zx.job matches 2 run scoreboard players set #jpanela zx.meta 1500
execute if score @s zx.job matches 3 run scoreboard players set #jpanelm zx.meta 800
execute if score @s zx.job matches 3 run scoreboard players set #jpanela zx.meta 800
execute if score @s zx.job matches 3 run scoreboard players set #jpanelo zx.meta 800
execute if score @s zx.job matches 4 run scoreboard players set #jpanelm zx.meta 700
execute if score @s zx.job matches 4 run scoreboard players set #jpanela zx.meta 1300
execute if score @s zx.job matches 4 if score @s zx.j_form matches 1 run scoreboard players set #jpanelm zx.meta 1100
execute if score @s zx.job matches 4 if score @s zx.j_form matches 1 run scoreboard players set #jpanela zx.meta 1100
execute if score @s zx.job matches 4 if score @s zx.j_form matches 1 run scoreboard players set #jpanelo zx.meta 1100
execute store result score #mp_src zx.meta run data get storage zx:work pl.smul_mm 1000
scoreboard players operation #mp_mul zx.meta = #jpanelm zx.meta
function sweetdream:lib/math/mul_permille
execute store result storage zx:work pl.smul_mm double .001 run scoreboard players get #mp_out zx.meta
execute store result score #mp_src zx.meta run data get storage zx:work pl.smul_atk 1000
scoreboard players operation #mp_mul zx.meta = #jpanela zx.meta
function sweetdream:lib/math/mul_permille
execute store result storage zx:work pl.smul_atk double .001 run scoreboard players get #mp_out zx.meta
execute store result score #mp_src zx.meta run data get storage zx:work pl.smul_oth 1000
scoreboard players operation #mp_mul zx.meta = #jpanelo zx.meta
function sweetdream:lib/math/mul_permille
execute store result storage zx:work pl.smul_oth double .001 run scoreboard players get #mp_out zx.meta
