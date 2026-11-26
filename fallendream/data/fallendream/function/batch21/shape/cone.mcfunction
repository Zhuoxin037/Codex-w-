function fallendream:batch21/shape/project
scoreboard players operation #s2_len zx.meta = #s2_dx zx.meta
scoreboard players operation #s2_len zx.meta *= #s2_dx zx.meta
scoreboard players operation #s2_temp zx.meta = #s2_dz zx.meta
scoreboard players operation #s2_temp zx.meta *= #s2_dz zx.meta
scoreboard players operation #s2_len zx.meta += #s2_temp zx.meta
scoreboard players operation #s2_rhs zx.meta = #s2_len zx.meta
scoreboard players operation #s2_rhs zx.meta *= #s2_norm zx.meta
scoreboard players operation #s2_lhs zx.meta = #s2_dot zx.meta
scoreboard players operation #s2_lhs zx.meta *= #s2_dot zx.meta
scoreboard players set #s2_four zx.meta 4
scoreboard players operation #s2_lhs zx.meta *= #s2_four zx.meta
execute if score #s2_len zx.meta matches 0 run tag @s add zx.s2_hit
execute if score #s2_dot zx.meta matches 1.. if score #s2_lhs zx.meta >= #s2_rhs zx.meta run tag @s add zx.s2_hit
