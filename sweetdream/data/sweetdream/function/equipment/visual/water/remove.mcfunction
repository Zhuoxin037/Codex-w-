execute unless score @s zx.sid matches 1.. run return 0
scoreboard players operation #water_link zx.meta = @s zx.sid
execute as @e[type=minecraft:item_display,tag=zx.water_visual,distance=0..] if score @s zx.fx_link = #water_link zx.meta run function sweetdream:equipment/visual/water/end
