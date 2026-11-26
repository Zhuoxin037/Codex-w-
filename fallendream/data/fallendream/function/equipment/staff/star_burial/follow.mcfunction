$execute unless entity $(target) run return run function fallendream:equipment/staff/star_burial/explode
$execute at $(target) run tp @s ~ ~ ~
$execute if data entity $(target) {Health:0.0f} at @s run return run function fallendream:equipment/staff/star_burial/explode
execute if entity @s run function fallendream:equipment/staff/star_burial/snapshot with entity @s data
