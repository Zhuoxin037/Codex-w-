execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["late_dusk"]}] run return 0
function sweetdream:equipment/armor/late_dusk/expire
execute if score @s zx.ld_r5 matches 1.. if score @s zx.ld_r5 <= #now manacore.meta run scoreboard players set @s zx.ld_r5 0
