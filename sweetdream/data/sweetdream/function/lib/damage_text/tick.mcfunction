execute if score @s zx.dt_end <= #now manacore.meta run return run function sweetdream:lib/damage_text/end
tp @s ~ ~0.025 ~
scoreboard players operation #dt_left zx.meta = @s zx.dt_end
scoreboard players operation #dt_left zx.meta -= #now manacore.meta
execute if score #dt_left zx.meta matches ..10 run execute store result entity @s text_opacity byte 20 run scoreboard players get #dt_left zx.meta
