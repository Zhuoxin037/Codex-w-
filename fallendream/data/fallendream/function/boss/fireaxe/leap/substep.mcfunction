function fallendream:boss/fireaxe/rush_air {step:0.25}
scoreboard players remove @s sdbf.lmove 1
execute if score @s sdbf.lmove matches 1.. if score @s sdbf.blocked matches 0 at @s run function fallendream:boss/fireaxe/leap/substep
