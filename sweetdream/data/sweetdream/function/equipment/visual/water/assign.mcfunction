$scoreboard players set @s zx.fx_link $(link)
$scoreboard players set @s zx.fx_life $(ticks)
# Logical owner deletes its visual at its exact end; one extra fallback tick avoids early disappearance.
scoreboard players add @s zx.fx_life 1
tag @s remove zx.water_new
