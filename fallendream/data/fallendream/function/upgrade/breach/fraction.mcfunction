scoreboard players operation #s2_fr_bit zx.meta = #s2_fr_n zx.meta
scoreboard players operation #s2_fr_bit zx.meta %= #s2_fr_two zx.meta
execute if score #s2_fr_bit zx.meta matches 1 run function fallendream:upgrade/breach/fraction_add
scoreboard players operation #s2_fr_n zx.meta /= #s2_fr_two zx.meta
execute unless score #s2_fr_n zx.meta matches 1.. run return 0
scoreboard players operation #s2_fr_q zx.meta *= #s2_fr_two zx.meta
scoreboard players operation #s2_fr_gap zx.meta = #s2_fr_d zx.meta
scoreboard players operation #s2_fr_gap zx.meta -= #s2_fr_r zx.meta
scoreboard players set #s2_fr_carry zx.meta 0
execute if score #s2_fr_r zx.meta >= #s2_fr_gap zx.meta run scoreboard players set #s2_fr_carry zx.meta 1
execute if score #s2_fr_carry zx.meta matches 1 run scoreboard players operation #s2_fr_r zx.meta -= #s2_fr_gap zx.meta
execute if score #s2_fr_carry zx.meta matches 1 run scoreboard players add #s2_fr_q zx.meta 1
execute unless score #s2_fr_carry zx.meta matches 1 run scoreboard players operation #s2_fr_r zx.meta *= #s2_fr_two zx.meta
function fallendream:upgrade/breach/fraction
