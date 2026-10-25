$execute unless entity @e[tag=zx.tjl_target_$(id)] run return run kill @s
$execute as @e[tag=zx.tjl_target_$(id),tag=zx.tjl_inside,limit=1] run function sweetdream:equipment/bow/tiejili/slow_apply
$execute if entity @e[tag=zx.tjl_target_$(id),tag=zx.tjl_inside] run return 0
data modify storage zx:work tj_restore set from entity @s data.fx
$execute as @e[tag=zx.tjl_target_$(id),limit=1] run function sweetdream:equipment/bow/tiejili/slow_exit with storage zx:work tj_restore
kill @s
