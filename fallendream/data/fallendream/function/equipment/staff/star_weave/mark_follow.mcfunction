$execute unless entity @e[type=!#fallendream:no_damage,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=0..,limit=1] run tag @s remove zx.weave_mark
execute unless entity @s[tag=zx.weave_mark] run return run kill @s
$execute at @e[type=!#fallendream:no_damage,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=0..,limit=1] run tp @s ~ ~ ~
