scoreboard players set #burial_six zx.meta 6
scoreboard players set #burial_ten zx.meta 10
scoreboard players operation #burial_loss zx.meta *= #burial_six zx.meta
scoreboard players operation #burial_loss zx.meta /= #burial_ten zx.meta
scoreboard players operation @s zx.burial_val += #burial_loss zx.meta
execute if score @s zx.burial_val > @s zx.burial_cap run scoreboard players operation @s zx.burial_val = @s zx.burial_cap
