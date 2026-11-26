$execute unless entity @e[type=!#fallendream:no_damage,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] run tag @s remove zx.wp_mark
execute unless entity @s[tag=zx.wp_mark] run return run kill @s
$execute at @e[type=!#fallendream:no_damage,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] run tp @s ~ ~ ~
