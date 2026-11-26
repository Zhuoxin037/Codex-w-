# These are this rig's passengers, never nearby bones from another knight.
execute if entity @s[tag=sd.kn.blink_bone] run return 0
scoreboard players set @s sdk.bview 1000
execute if data entity @s view_range store result score @s sdk.bview run data get entity @s view_range 1000
data modify entity @s view_range set value 0f
tag @s add sd.kn.blink_bone
