function fallendream:boss/b_staff/move/try {step:-0.25}
execute if score #moved bs.ok matches 0 run scoreboard players set @s bs.path 0
