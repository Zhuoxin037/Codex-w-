# hp_snap was advanced by the current tick or the shared hurt event.
function sweetdream:lib/max_health_score
scoreboard players operation #max_hp zx.meta /= #2 zx.meta
execute if score @s zx.hp_snap < #max_hp zx.meta run scoreboard players set @s zx.wb_low 1
