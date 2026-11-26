function fallendream:boss/b_staff/move/try {step:0.0625}
execute if score #moved bs.ok matches 1 run scoreboard players set @s bs.dir 1
