$data modify storage zx:work mark_owner set value {target:"$(target)",mark:"$(mark)",u0:0,u1:0,u2:0,u3:0}
$execute as $(by) if entity @s[type=minecraft:player] store result storage zx:work mark_owner.u0 int 1 run scoreboard players get @s manacore.u0
$execute as $(by) if entity @s[type=minecraft:player] store result storage zx:work mark_owner.u1 int 1 run scoreboard players get @s manacore.u1
$execute as $(by) if entity @s[type=minecraft:player] store result storage zx:work mark_owner.u2 int 1 run scoreboard players get @s manacore.u2
$execute as $(by) if entity @s[type=minecraft:player] store result storage zx:work mark_owner.u3 int 1 run scoreboard players get @s manacore.u3
function sweetdream:tag/mark_owned with storage zx:work mark_owner
