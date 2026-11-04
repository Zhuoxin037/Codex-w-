execute store result score #s2_due zx.meta run data get storage zx:work s2_queue[0].end
execute if score #s2_due zx.meta < @s zx.s2_abs_next run scoreboard players operation @s zx.s2_abs_next = #s2_due zx.meta
data remove storage zx:work s2_queue[0]
execute if data storage zx:work s2_queue[0] run function sweetdream:batch21/shield/next
