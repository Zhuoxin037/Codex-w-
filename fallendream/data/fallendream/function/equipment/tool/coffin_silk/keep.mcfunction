# 殓结私有状态维护：每刻及获得/兑现前调用；不更改 12 秒触发冷却。
# 只维护殓丝自己的殓结，不改五种通用标签的固定衰减。
execute unless entity @s[tag=zx.cfs_knot] run return 0
execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["coffin_silk"]}] run tag @s remove zx.cfs_knot
execute unless score @s zx.cfs_end > #now manacore.meta run tag @s remove zx.cfs_knot
execute unless entity @s[tag=zx.cfs_knot] run scoreboard players reset @s zx.cfs_end
