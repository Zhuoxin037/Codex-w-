execute unless score @s zx.ex_until > #now manacore.meta run return run kill @s
scoreboard players operation #ex_fx zx.meta = #now manacore.meta
scoreboard players set #ex_twenty zx.meta 20
scoreboard players operation #ex_fx zx.meta %= #ex_twenty zx.meta
execute if score #ex_fx zx.meta matches 0 run particle minecraft:soul ~ ~0.15 ~ 8 0.1 8 0.01 18 normal
