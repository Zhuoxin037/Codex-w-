# 兼容旧版本：保留仍可读取的状态；也从旧编号对应的图标恢复显示过的状态。
# 普通生物已丢失且没有旧图标的自定义 NBT 无法追溯，须重新施加。
execute if data entity @s data.zx.status{yuanhai:1b} run tag @s add zx.status.yuanhai
execute if data entity @s data.zx.status{liuhuo:1b} run tag @s add zx.status.liuhuo
execute if data entity @s data.zx.status{yehuo:1b} run tag @s add zx.status.yehuo
execute if data entity @s data.zx.status{shixin:1b} run tag @s add zx.status.shixin
execute if data entity @s data.zx.status{dream:1b} run tag @s add zx.status.dream
execute if score @s zx.icon_id matches 1.. store result storage zx:tag legacy.id int 1 run scoreboard players get @s zx.icon_id
execute if score @s zx.icon_id matches 1.. run function sweetdream:tag/migrate_icons with storage zx:tag legacy
scoreboard players reset @s zx.icon_id
tag @s add zx.tags_v2
