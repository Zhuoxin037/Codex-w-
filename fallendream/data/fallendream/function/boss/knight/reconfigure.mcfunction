# Update already-summoned bodies once, preserving health/phase/aggro.
attribute @s minecraft:scale base set 2.25
data modify entity @s CustomName set value {"text":"\"骑士\""}
data modify entity @s CustomNameVisible set value 0b
execute store result storage fallendream:knight args.id int 1 run scoreboard players get @s sdk.id
function fallendream:boss/knight/rename_bar with storage fallendream:knight args
tag @s add sd.kn.feedback_v2
