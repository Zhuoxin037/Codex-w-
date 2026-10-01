# 风行枝冠动画的实际运行时依赖，不能作为建模临时文件删除。
# objectives add 重载时已存在会提示失败，但不会中止后续命令。
scoreboard objectives add nw.anim dummy
scoreboard players set #clock nw.anim 0
scoreboard players add #frame nw.anim 0
execute unless score #frame nw.anim matches 0..15 run scoreboard players set #frame nw.anim 0
