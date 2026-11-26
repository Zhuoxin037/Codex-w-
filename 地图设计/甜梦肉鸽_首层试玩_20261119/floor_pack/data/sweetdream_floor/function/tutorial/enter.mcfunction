execute unless entity @a[tag=sd.floor_tutorial] run scoreboard players set #edu_live sd.floor 0
tag @s add sd.floor_tutorial
execute in minecraft:overworld run tp @s -101.5 90 48.5 -90 0
tellraw @s {"text":"右键讲台读本段说明。按「下一个」切换演示。","color":"aqua"}
