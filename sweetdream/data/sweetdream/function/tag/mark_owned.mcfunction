# Freeze owner UUID as macro literals for every actual target; @s keeps its original meaning.
$execute as $(target) at @s unless entity @s[type=minecraft:player] if data entity @s Health unless data entity @s {Health:0.0f} run function sweetdream:tag/mark_one_owned {mark:"$(mark)",u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
