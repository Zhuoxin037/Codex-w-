scoreboard players add @s zx.j_orb 0
scoreboard players add @s zx.j_prop 0
scoreboard players operation #jorbs zx.meta = @s zx.j_orb
scoreboard players operation #jorbs zx.meta += @s zx.j_prop
scoreboard players set #jcap zx.meta 3
execute if score @s zx.j_aw matches 1 run scoreboard players set #jcap zx.meta 5
