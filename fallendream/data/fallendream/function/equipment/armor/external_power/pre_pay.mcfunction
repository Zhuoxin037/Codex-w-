scoreboard players set @s zx.ep_pre 0
scoreboard players operation @s zx.ep_pre_t = #now manacore.meta
data modify storage zx:work ep_pre_arg set from storage manacore:in arg
function manacore:api/mana/get
scoreboard players set #ep_before zx.meta 0
scoreboard players set #ep_max zx.meta 0
execute store result score #ep_before zx.meta run data get storage manacore:out r.value 1000
execute store result score #ep_max zx.meta run data get storage manacore:out r.max 1000
scoreboard players operation #mp_src zx.meta = #ep_max zx.meta
scoreboard players set #mp_mul zx.meta 700
function fallendream:lib/math/mul_permille
execute if score #ep_before zx.meta > #mp_out zx.meta run scoreboard players set @s zx.ep_pre 1
data modify storage manacore:in arg set from storage zx:work ep_pre_arg
data remove storage zx:work ep_pre_arg
