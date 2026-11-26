function fallendream:boss/b_staff/shot/setup
scoreboard players operation #damage bs.dmg = #cast_three bs.cfg
scoreboard players set #limit bs.limit 2
scoreboard players set #interval bs.interval 10
execute positioned ^-0.9256657 ^3.3229399 ^0.8656881 facing entity @e[tag=sd.bs.target,distance=0..,limit=1] eyes run function fallendream:boss/b_staff/fx/bolt
