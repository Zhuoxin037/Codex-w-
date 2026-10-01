# 状态 -> 位掩码 -> 一个图标行。没有改变的文字不重复发送到客户端。
execute unless entity @s[tag=zx.tags_v2] run function sweetdream:tag/migrate
function sweetdream:tag/identity
scoreboard players set #tag_mask zx.meta 0
execute if entity @s[tag=zx.status.yuanhai] run scoreboard players add #tag_mask zx.meta 1
execute if entity @s[tag=zx.status.liuhuo] run scoreboard players add #tag_mask zx.meta 2
execute if entity @s[tag=zx.status.yehuo] run scoreboard players add #tag_mask zx.meta 4
execute if entity @s[tag=zx.status.shixin] run scoreboard players add #tag_mask zx.meta 8
execute if entity @s[tag=zx.status.dream] run scoreboard players add #tag_mask zx.meta 16
# 正在死亡的生物不继续显示；不能以仍存在实体就认定它还活着。
execute if data entity @s {Health:0.0f} run scoreboard players set #tag_mask zx.meta 0
execute store result storage zx:tag owner.mask int 1 run scoreboard players get #tag_mask zx.meta
execute if score #tag_mask zx.meta matches 1.. run tag @s add zx.tagged
execute if score #tag_mask zx.meta matches 1.. run function sweetdream:tag/icon_sync with storage zx:tag owner
execute if score #tag_mask zx.meta matches 0 run function sweetdream:tag/icon_kill with storage zx:tag owner
execute if score #tag_mask zx.meta matches 0 run tag @s remove zx.tagged
