execute store result storage fallendream:b_staff args.id int 1 run scoreboard players get @s bs.id
execute as @e[tag=sd.bs.target,distance=0..,limit=1] at @s anchored eyes positioned ^ ^ ^ run execute summon minecraft:marker run function fallendream:boss/b_staff/aim/capture_point with storage fallendream:b_staff args
