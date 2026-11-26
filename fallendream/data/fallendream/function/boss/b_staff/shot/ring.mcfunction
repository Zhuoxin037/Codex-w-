function fallendream:boss/b_staff/shot/setup
scoreboard players operation #damage bs.dmg = #ring_wave bs.cfg
scoreboard players set #limit bs.limit 1
scoreboard players set #interval bs.interval 0
execute rotated ~ 0 positioned ^-1.1111405 ^0.25 ^1.6629392 rotated ~33.75 0 run function fallendream:boss/b_staff/fx/ring_new
execute rotated ~ 0 positioned ^-1.6629392 ^0.25 ^1.1111405 rotated ~56.25 0 run function fallendream:boss/b_staff/fx/ring_new
execute rotated ~ 0 positioned ^-1.9615706 ^0.25 ^0.3901806 rotated ~78.75 0 run function fallendream:boss/b_staff/fx/ring_new
execute rotated ~ 0 positioned ^-1.9615706 ^0.25 ^-0.3901806 rotated ~101.25 0 run function fallendream:boss/b_staff/fx/ring_new
execute rotated ~ 0 positioned ^-1.6629392 ^0.25 ^-1.1111405 rotated ~123.75 0 run function fallendream:boss/b_staff/fx/ring_new
execute rotated ~ 0 positioned ^-1.1111405 ^0.25 ^-1.6629392 rotated ~146.25 0 run function fallendream:boss/b_staff/fx/ring_new
execute rotated ~ 0 positioned ^1.1111405 ^0.25 ^-1.6629392 rotated ~213.75 0 run function fallendream:boss/b_staff/fx/ring_new
execute rotated ~ 0 positioned ^1.6629392 ^0.25 ^-1.1111405 rotated ~236.25 0 run function fallendream:boss/b_staff/fx/ring_new
execute rotated ~ 0 positioned ^1.9615706 ^0.25 ^-0.3901806 rotated ~258.75 0 run function fallendream:boss/b_staff/fx/ring_new
execute rotated ~ 0 positioned ^1.9615706 ^0.25 ^0.3901806 rotated ~281.25 0 run function fallendream:boss/b_staff/fx/ring_new
execute rotated ~ 0 positioned ^1.6629392 ^0.25 ^1.1111405 rotated ~303.75 0 run function fallendream:boss/b_staff/fx/ring_new
execute rotated ~ 0 positioned ^1.1111405 ^0.25 ^1.6629392 rotated ~326.25 0 run function fallendream:boss/b_staff/fx/ring_new
