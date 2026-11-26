execute if entity @s[tag=zx.ff_homing] if data entity @s data.target run function fallendream:equipment/staff/firefly_staff/fly_homing with entity @s data
execute if entity @s[tag=zx.ff_homing] unless data entity @s data.target run tag @s remove zx.ff_homing
execute unless entity @s[tag=zx.ff_homing] positioned ^ ^ ^0.6 run tp @s ~ ~ ~
execute at @s run function fallendream:equipment/staff/firefly_staff/fly_check
