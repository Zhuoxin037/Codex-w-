scoreboard players set #s2_full zx.meta 3
execute if score @s zx.j_aw matches 1 run scoreboard players set #s2_full zx.meta 5
execute unless score @s zx.j_orb = #s2_full zx.meta run scoreboard players set @s zx.s2_sky_full 0
execute unless score @s zx.j_orb = #s2_full zx.meta run return 0
scoreboard players add @s zx.s2_sky_full 1
execute if score @s zx.s2_sky_full matches 120.. run function sweetdream:equipment/armor/still_sky/ready
