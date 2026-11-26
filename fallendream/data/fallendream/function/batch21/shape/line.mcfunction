execute store result score #s2_dy zx.meta run data get entity @s Pos[1] 10
scoreboard players operation #s2_dy zx.meta -= #s2_py zx.meta
execute unless score #s2_dy zx.meta matches -20..20 run return 0
function fallendream:batch21/shape/project
execute if score #s2_dot zx.meta matches 0..8000 if score #s2_cross zx.meta matches -1000..1000 run tag @s add zx.s2_hit
