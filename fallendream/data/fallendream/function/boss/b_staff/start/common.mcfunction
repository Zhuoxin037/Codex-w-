execute store result storage fallendream:b_staff args.id int 1 run scoreboard players get @s bs.id
function fallendream:boss/b_staff/cleanup_cast with storage fallendream:b_staff args
scoreboard players add #serial bs.cast 1
scoreboard players operation @s bs.cast = #serial bs.cast
scoreboard players set @s bs.age 0
scoreboard players set @s bs.shock 0
scoreboard players set @s bs.dir 0
