# Snapshot only the successful cast's colours before gameplay clears the slots.
scoreboard players set @s zx.pv_c1 0
scoreboard players set @s zx.pv_c2 0
execute if score @s zx.pal_c1 matches 1..3 run scoreboard players operation @s zx.pv_c1 = @s zx.pal_c1
execute if score @s zx.pal_c2 matches 1..3 run scoreboard players operation @s zx.pv_c2 = @s zx.pal_c2
scoreboard players set @s zx.pv_age 0
function sweetdream:equipment/staff/palette/visual/held
