scoreboard players operation @s zx.j_bloom = @s zx.j_bloom_end
scoreboard players operation @s zx.j_bloom -= #now manacore.meta
execute if score @s zx.j_bloom matches ..-1 run scoreboard players set @s zx.j_bloom 0
