execute if entity @s[tag=zx.s2_shield] if score @s zx.s2_abs_next <= #now manacore.meta run function sweetdream:batch21/shield/tick
execute if score @s zx.job matches 1 if items entity @s armor.head *[custom_data~{zx:["still_sky"]}] run function sweetdream:equipment/armor/still_sky/tick
execute unless score @s zx.job matches 1 run scoreboard players set @s zx.s2_sky_full 0
execute unless items entity @s armor.head *[custom_data~{zx:["still_sky"]}] run scoreboard players set @s zx.s2_sky_full 0
execute unless items entity @s armor.head *[custom_data~{zx:["still_sky"]}] run scoreboard players set @s zx.s2_sky_end 0
execute if score @s zx.s2_stage matches 1.. unless score @s zx.s2_stage_end > #now manacore.meta run scoreboard players set @s zx.s2_stage 0
execute if score @s zx.s2_rail matches 1.. unless score @s zx.s2_rail_end > #now manacore.meta run scoreboard players set @s zx.s2_rail 0
execute if entity @s[tag=zx.s2_cw] run function sweetdream:equipment/armor/cease_war/tick
execute unless score @s zx.j_reborn matches 1.. run scoreboard players set @s zx.s2_veil_rec 0
execute unless items entity @s armor.head *[custom_data~{zx:["rebirth_veil"]}] run scoreboard players set @s zx.s2_veil_rec 0
scoreboard players set @s zx.s2_sky_view 0
execute if score @s zx.s2_sky_end > #now manacore.meta run scoreboard players set @s zx.s2_sky_view 1
scoreboard players set @s zx.s2_cw_view 0
execute if entity @s[tag=zx.s2_cw] run scoreboard players set @s zx.s2_cw_view 1
