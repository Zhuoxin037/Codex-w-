scoreboard players operation #s2_fr_oq zx.meta += #s2_fr_q zx.meta
scoreboard players operation #s2_fr_gap zx.meta = #s2_fr_d zx.meta
scoreboard players operation #s2_fr_gap zx.meta -= #s2_fr_r zx.meta
execute if score #s2_fr_or zx.meta >= #s2_fr_gap zx.meta run return run function fallendream:upgrade/breach/fraction_carry
scoreboard players operation #s2_fr_or zx.meta += #s2_fr_r zx.meta
