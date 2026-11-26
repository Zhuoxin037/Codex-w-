function fallendream:boss/b_staff/shot/setup
scoreboard players operation #damage bs.dmg = #fan_volley bs.cfg
scoreboard players set #limit bs.limit 1
scoreboard players set #interval bs.interval 0
function fallendream:boss/b_staff/aim/read
execute positioned ^-0.9061693 ^3.4341265 ^0.8385906 run function fallendream:boss/b_staff/shot/fan_locked with storage fallendream:b_staff aim
