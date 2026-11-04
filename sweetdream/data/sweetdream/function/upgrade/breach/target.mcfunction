execute unless data storage zx:work a.s2_b_num.n run return 0
execute if data storage zx:work a{fixed:1b} run return 0
execute if data storage zx:work a{src:"enemy"} run return 0
scoreboard players set #s2_br_armor zx.meta 0
execute store result score #s2_br_armor zx.meta run attribute @s minecraft:armor get 100
execute unless score #s2_br_armor zx.meta matches 1000.. run return 0
execute store result score #s2_fr_n zx.meta run data get storage zx:work a.s2_b_num.n
execute store result score #s2_fr_d zx.meta run data get storage zx:work a.s2_b_num.d
execute unless score #s2_fr_n zx.meta matches 1.. run return 0
execute unless score #s2_fr_d zx.meta matches 1.. run return 0
execute store result score #s2_br_value zx.meta run data get storage zx:work a.num 1000
scoreboard players operation #s2_fr_q zx.meta = #s2_br_value zx.meta
scoreboard players operation #s2_fr_q zx.meta /= #s2_fr_d zx.meta
scoreboard players operation #s2_fr_r zx.meta = #s2_br_value zx.meta
scoreboard players operation #s2_fr_r zx.meta %= #s2_fr_d zx.meta
scoreboard players set #s2_fr_oq zx.meta 0
scoreboard players set #s2_fr_or zx.meta 0
scoreboard players set #s2_fr_two zx.meta 2
function sweetdream:upgrade/breach/fraction
scoreboard players operation #s2_br_value zx.meta += #s2_fr_oq zx.meta
execute store result storage zx:work a.num double .001 run scoreboard players get #s2_br_value zx.meta
function sweetdream:lib/num/plain
