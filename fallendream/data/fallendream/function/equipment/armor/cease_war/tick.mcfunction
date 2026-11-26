execute unless score @s zx.job matches 2 run return run function fallendream:equipment/armor/cease_war/end
execute unless items entity @s armor.chest *[custom_data~{zx:["cease_war"]}] run return run function fallendream:equipment/armor/cease_war/end
execute unless score @s zx.s2_cw_end > #now manacore.meta run function fallendream:equipment/armor/cease_war/end
