execute store result score #mp_src zx.meta run data get storage manacore:out r.damage 1000
scoreboard players set #mp_mul zx.meta 1800
function sweetdream:lib/math/mul_permille
execute store result storage manacore:out r.damage double .001 run scoreboard players get #mp_out zx.meta
