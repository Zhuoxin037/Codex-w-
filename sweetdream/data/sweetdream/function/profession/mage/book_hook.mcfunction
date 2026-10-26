# @calc: indep
execute unless entity @s[type=minecraft:player] run return 0
execute unless score @s zx.j_book_t = #now manacore.meta run return 0
scoreboard players set #jbookseg zx.meta 0
execute store result score #jbookseg zx.meta run data get storage manacore:out r.seg_m
execute unless score #jbookseg zx.meta matches 1.. run return 0
# The independent 10% affects only the already-class/additive-scaled mana component.
scoreboard players operation #mp_src zx.meta = #jbookseg zx.meta
execute store result score #mp_mul zx.meta run data get storage zx:work add.mm 1000
scoreboard players add #mp_mul zx.meta 1000
function sweetdream:lib/math/mul_permille
scoreboard players operation #jbookseg zx.meta = #mp_out zx.meta
execute store result score #jbookim zx.meta run data get storage manacore:out r.im
function manacore:internal/damage/mul_pct {src:"#jbookseg",mul:"#jbookim",obj:"zx.meta"}
scoreboard players operation #jbookseg zx.meta = #mul_out zx.meta
scoreboard players operation #jbookseg zx.meta /= #j10 zx.meta
execute store result score #jbookfinal zx.meta run data get storage manacore:out r.damage 1000
scoreboard players operation #jbookfinal zx.meta += #jbookseg zx.meta
execute store result storage manacore:out r.damage double .001 run scoreboard players get #jbookfinal zx.meta
