# 只认旧图标实体和旧编号，不触及其他系统的实体。
$execute if entity @e[type=minecraft:text_display,tag=zx.icon,tag=zx.icon_$(id)_yuanhai] run tag @s add zx.status.yuanhai
$execute if entity @e[type=minecraft:text_display,tag=zx.icon,tag=zx.icon_$(id)_liuhuo] run tag @s add zx.status.liuhuo
$execute if entity @e[type=minecraft:text_display,tag=zx.icon,tag=zx.icon_$(id)_yehuo] run tag @s add zx.status.yehuo
$execute if entity @e[type=minecraft:text_display,tag=zx.icon,tag=zx.icon_$(id)_shixin] run tag @s add zx.status.shixin
$execute if entity @e[type=minecraft:text_display,tag=zx.icon,tag=zx.icon_$(id)_dream] run tag @s add zx.status.dream
$kill @e[type=minecraft:text_display,tag=zx.icon,tag=zx.n$(id)]
