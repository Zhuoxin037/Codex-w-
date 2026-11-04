execute unless score @s zx.s2_sky_end > #now manacore.meta run return 0
execute unless score @s zx.j_orb matches 1.. run return 0
scoreboard players remove @s zx.j_orb 1
scoreboard players set @s zx.s2_sky_end 0
scoreboard players set @s zx.s2_sky_full 0
scoreboard players set #s2_g_v zx.meta 5000
scoreboard players set #s2_g_t zx.meta 80
function sweetdream:batch21/shield/grant
effect give @e[tag=zx.s2_source,distance=0..,limit=1] minecraft:slowness 2 2 true
