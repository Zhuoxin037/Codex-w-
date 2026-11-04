execute store result score #wst_dx zx.meta run data get entity @s Pos[0] 10
execute store result score #wst_dz zx.meta run data get entity @s Pos[2] 10
scoreboard players operation #wst_dx zx.meta -= #wst_px zx.meta
scoreboard players operation #wst_dz zx.meta -= #wst_pz zx.meta
scoreboard players operation #wst_dot zx.meta = #wst_dx zx.meta
scoreboard players operation #wst_dot zx.meta *= #wst_fx zx.meta
scoreboard players operation #wst_temp zx.meta = #wst_dz zx.meta
scoreboard players operation #wst_temp zx.meta *= #wst_fz zx.meta
scoreboard players operation #wst_dot zx.meta += #wst_temp zx.meta
scoreboard players operation #wst_len zx.meta = #wst_dx zx.meta
scoreboard players operation #wst_len zx.meta *= #wst_dx zx.meta
scoreboard players operation #wst_temp zx.meta = #wst_dz zx.meta
scoreboard players operation #wst_temp zx.meta *= #wst_dz zx.meta
scoreboard players operation #wst_len zx.meta += #wst_temp zx.meta
scoreboard players operation #wst_rhs zx.meta = #wst_len zx.meta
scoreboard players operation #wst_rhs zx.meta *= #wst_norm zx.meta
scoreboard players operation #wst_lhs zx.meta = #wst_dot zx.meta
scoreboard players operation #wst_lhs zx.meta *= #wst_dot zx.meta
scoreboard players set #wst_two zx.meta 2
scoreboard players operation #wst_lhs zx.meta *= #wst_two zx.meta
execute if score #wst_len zx.meta matches 0 run tag @s add zx.ws_in
execute if score #wst_dot zx.meta matches 1.. if score #wst_lhs zx.meta >= #wst_rhs zx.meta run tag @s add zx.ws_in
