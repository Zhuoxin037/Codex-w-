$execute unless entity @e[type=!#fallendream:no_damage,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] run tag @s remove zx.cr_mark
execute unless entity @s[tag=zx.cr_mark] run return run kill @s
$execute at @e[type=!#fallendream:no_damage,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] run tp @s ~ ~ ~
