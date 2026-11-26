# Read-only damage/display predicate. Green/yellow alone give no damage bonus.
scoreboard players set #gl_mode zx.meta 0
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["glimmer"]}] run return 0
execute if score @s zx.gl_wt matches 1.. if score @s zx.gl_wt <= #now manacore.meta run return 0
execute if score @s zx.gl_r matches 1 run scoreboard players set #gl_mode zx.meta 1
execute if score @s zx.gl_r matches 1 if score @s zx.gl_g matches 1 if score @s zx.gl_y matches 1 run scoreboard players set #gl_mode zx.meta 2
