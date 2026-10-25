scoreboard players set #mp_src zx.meta 1000
execute store result score #mp_src zx.meta run data get storage zx:work pl.smul_mm 1000
scoreboard players set #mp_mul zx.meta 0
execute store result score #mp_mul zx.meta run data get storage zx:work add.mm 1000
scoreboard players add #mp_mul zx.meta 1000
function sweetdream:lib/math/mul_permille
execute store result storage zx:work pl.smul_mm double 0.001 run scoreboard players get #mp_out zx.meta


scoreboard players set #mp_src zx.meta 1000
execute store result score #mp_src zx.meta run data get storage zx:work pl.smul_atk 1000
scoreboard players set #mp_mul zx.meta 0
execute store result score #mp_mul zx.meta run data get storage zx:work add.atk 1000
scoreboard players add #mp_mul zx.meta 1000
function sweetdream:lib/math/mul_permille
execute store result storage zx:work pl.smul_atk double 0.001 run scoreboard players get #mp_out zx.meta


scoreboard players set #mp_src zx.meta 1000
execute store result score #mp_src zx.meta run data get storage zx:work pl.smul_oth 1000
scoreboard players set #mp_mul zx.meta 0
execute store result score #mp_mul zx.meta run data get storage zx:work add.oth 1000
scoreboard players add #mp_mul zx.meta 1000
function sweetdream:lib/math/mul_permille
execute store result storage zx:work pl.smul_oth double 0.001 run scoreboard players get #mp_out zx.meta
