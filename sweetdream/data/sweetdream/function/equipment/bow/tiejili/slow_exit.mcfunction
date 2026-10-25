# Clear only the field signature, restoring the saved external effect with elapsed time removed.
execute if data entity @s active_effects[{id:"minecraft:slowness",amplifier:1,ambient:1b,show_icon:0b}] run function sweetdream:equipment/bow/tiejili/slow_restore
$tag @s remove zx.tjl_target_$(id)
tag @s remove zx.tjl_managed
