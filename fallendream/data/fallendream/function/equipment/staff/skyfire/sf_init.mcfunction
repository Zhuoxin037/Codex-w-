# @s = 刚生成的延迟火球 marker, 位置 = 命中点。从 zx:work sf 抄射手 UUID 与形态。
data modify entity @s data.zx set from storage zx:work sf
scoreboard players operation @s zx.sf_due = #now manacore.meta
execute if data entity @s data.zx{emp:1} run scoreboard players add @s zx.sf_due 20
execute unless data entity @s data.zx{emp:1} run scoreboard players add @s zx.sf_due 40
particle minecraft:flame ~ ~0.3 ~ 0.2 0.2 0.2 0.01 6 normal
