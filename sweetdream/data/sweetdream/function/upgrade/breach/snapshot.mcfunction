data modify storage manacore:out r.s2_b_damage set value {n:0,d:1}
scoreboard players set #s2_bp zx.meta 0
execute if entity @s[type=minecraft:player] if items entity @s weapon.mainhand *[custom_data~{up:["breach_a"]}] run scoreboard players set #s2_bp zx.meta 80
execute if entity @s[type=minecraft:player] if items entity @s weapon.mainhand *[custom_data~{up:["breach_b"]}] run scoreboard players set #s2_bp zx.meta 140
execute if entity @s[type=minecraft:player] if items entity @s weapon.mainhand *[custom_data~{up:["breach_o"]}] run scoreboard players set #s2_bp zx.meta 200
execute unless score #s2_bp zx.meta matches 1.. run return 0
scoreboard players set #s2_bseg zx.meta 0
scoreboard players set #s2_btmp zx.meta 0
execute store result score #s2_bseg zx.meta run data get storage manacore:out r.seg_m
execute store result score #s2_btmp zx.meta run data get storage manacore:out r.seg_a
scoreboard players operation #s2_bseg zx.meta += #s2_btmp zx.meta
scoreboard players set #s2_btmp zx.meta 0
execute store result score #s2_btmp zx.meta run data get storage manacore:out r.seg_o
scoreboard players operation #s2_bseg zx.meta += #s2_btmp zx.meta
scoreboard players operation #mp_src zx.meta = #s2_bseg zx.meta
scoreboard players operation #mp_mul zx.meta = #s2_bp zx.meta
function sweetdream:lib/math/mul_permille
scoreboard players operation #s2_bseg zx.meta = #mp_out zx.meta
scoreboard players set #s2_bim zx.meta 100
execute store result score #s2_bim zx.meta run data get storage manacore:out r.im
function manacore:internal/damage/mul_pct {src:"#s2_bseg",mul:"#s2_bim",obj:"zx.meta"}
scoreboard players operation #s2_bextra zx.meta = #mul_out zx.meta
scoreboard players set #s2_bbase zx.meta 0
execute store result score #s2_bbase zx.meta run data get storage manacore:out r.damage 1000
execute unless score #s2_bbase zx.meta matches 1.. run return 0

data modify storage manacore:out r.s2_b_damage set value {n:0,d:1}
execute store result storage manacore:out r.s2_b_damage.n int 1 run scoreboard players get #s2_bextra zx.meta
execute store result storage manacore:out r.s2_b_damage.d int 1 run scoreboard players get #s2_bbase zx.meta
