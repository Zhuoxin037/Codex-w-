$attribute @s minecraft:max_health modifier add sweetdream:no_return_clamp $(amount) add_value
tag @s add zx.nr_clamp
scoreboard players operation @s zx.nr_clamp_end = #now manacore.meta
scoreboard players add @s zx.nr_clamp_end 2
