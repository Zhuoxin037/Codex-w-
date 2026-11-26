execute unless entity @s[tag=sd.kn.blink_hidden] run return 0
execute on passengers run function fallendream:boss/knight/blink/show_bone
tag @s remove sd.kn.blink_hidden
