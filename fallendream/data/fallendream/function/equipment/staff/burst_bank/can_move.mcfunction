# 当前执行位置/朝向的下一步：平推，其次单格抬升；两路都不通才停。
scoreboard players set #bb_mv zx.meta 0
execute positioned ^ ^ ^0.5 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run scoreboard players set #bb_mv zx.meta 1
execute if score #bb_mv zx.meta matches 0 positioned ^ ^ ^0.5 if block ~ ~1 ~ #minecraft:replaceable if block ~ ~2 ~ #minecraft:replaceable run scoreboard players set #bb_mv zx.meta 2
