execute store result score #s2_dx zx.meta run data get entity @s Pos[0] 10
execute store result score #s2_dz zx.meta run data get entity @s Pos[2] 10
scoreboard players operation #s2_dx zx.meta -= #s2_px zx.meta
scoreboard players operation #s2_dz zx.meta -= #s2_pz zx.meta
scoreboard players operation #s2_dot zx.meta = #s2_dx zx.meta
scoreboard players operation #s2_dot zx.meta *= #s2_fx zx.meta
scoreboard players operation #s2_temp zx.meta = #s2_dz zx.meta
scoreboard players operation #s2_temp zx.meta *= #s2_fz zx.meta
scoreboard players operation #s2_dot zx.meta += #s2_temp zx.meta
scoreboard players operation #s2_cross zx.meta = #s2_dx zx.meta
scoreboard players operation #s2_cross zx.meta *= #s2_fz zx.meta
scoreboard players operation #s2_temp zx.meta = #s2_dz zx.meta
scoreboard players operation #s2_temp zx.meta *= #s2_fx zx.meta
scoreboard players operation #s2_cross zx.meta -= #s2_temp zx.meta
