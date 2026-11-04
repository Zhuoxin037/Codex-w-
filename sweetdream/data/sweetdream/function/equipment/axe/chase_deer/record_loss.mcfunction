execute unless score @s zx.s2_stage_end > #now manacore.meta run return 0
execute store result score #s2_self_after zx.meta run data get entity @s Health 1000
scoreboard players operation #s2_self_lost zx.meta = @s zx.s2_selfpre
scoreboard players operation #s2_self_lost zx.meta -= #s2_self_after zx.meta
execute if score #s2_self_lost zx.meta matches 1.. run scoreboard players operation @s zx.s2_loss += #s2_self_lost zx.meta
