execute store result storage fallendream:b_staff args.id int 1 run scoreboard players get @s bs.id
execute positioned ^-0.9061693 ^3.4341265 ^0.8385906 facing entity @e[tag=sd.bs.target,distance=0..,limit=1] eyes run execute summon minecraft:marker run function fallendream:boss/b_staff/aim/capture with storage fallendream:b_staff args
