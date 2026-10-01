# 猪的眼睛应高于脚；倾斜朝向不能把竖直偏移变成前后偏移。
execute store result score #tag_y zx.meta run data get entity @s Pos[1] 1000
$execute store result score #tag_iy zx.meta run data get entity @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),limit=1] Pos[1] 1000
scoreboard players operation #tag_iy zx.meta -= #tag_y zx.meta
execute unless score #tag_iy zx.meta matches 1200..1400 run function sweetdream:debug/tag_test/fail {case:"eyes anchor height"}
