function sweetdream:boss/fireaxe/rush_air {step:0.25}
scoreboard players remove @s sdbf.lmove 1
execute if score @s sdbf.lmove matches 1.. if score @s sdbf.blocked matches 0 at @s run function sweetdream:boss/fireaxe/leap/substep
