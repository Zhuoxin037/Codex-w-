# #ld_gn is the number of successful applications. Common expiry refreshes on gain.
execute unless score #ld_gn zx.meta matches 1.. run return 0
function sweetdream:equipment/armor/late_dusk/expire
scoreboard players add @s zx.ld_s 0
execute if score #ld_gn zx.meta matches 4.. run scoreboard players set #ld_gn zx.meta 3
scoreboard players operation @s zx.ld_s += #ld_gn zx.meta
execute if score @s zx.ld_s matches 4.. run scoreboard players set @s zx.ld_s 3
scoreboard players operation @s zx.ld_t = #now manacore.meta
scoreboard players add @s zx.ld_t 160
scoreboard players set #ld_gn zx.meta 0
particle minecraft:dust{color:[0.55,0.45,0.75],scale:1.3} ~ ~1.2 ~ 0.4 0.4 0.4 0.02 14
playsound minecraft:block.amethyst_block.chime player @s ~ ~ ~ 0.45 1.2
