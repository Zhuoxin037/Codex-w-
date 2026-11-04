function sweetdream:equipment/staff/star_burial/follow with entity @s data
execute unless entity @s[tag=zx.burial_core] run return 0
execute unless score @s zx.burial_end > #now manacore.meta at @s run function sweetdream:equipment/staff/star_burial/explode
