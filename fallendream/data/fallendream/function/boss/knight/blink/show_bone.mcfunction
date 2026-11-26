execute unless entity @s[tag=sd.kn.blink_bone] run return 0
execute store result entity @s view_range float 0.001 run scoreboard players get @s sdk.bview
tag @s remove sd.kn.blink_bone
scoreboard players reset @s sdk.bview
