$execute as $(by) if entity @s[type=minecraft:player] run function sweetdream:lib/dream_check {target:"$(target)",mark:"$(mark)"}
$execute as $(target) at @s unless entity @s[type=minecraft:player] if data entity @s Health unless data entity @s {Health:0.0f} run function sweetdream:tag/mark_one {mark:"$(mark)"}
