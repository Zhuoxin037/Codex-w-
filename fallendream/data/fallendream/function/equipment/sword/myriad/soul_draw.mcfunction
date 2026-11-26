# 宏: 绕着玩家画"剑魂"($(a) = 整体旋转角)。每个槽位按剑魂数决定画不画。
$execute if score @s zx.mq_soul matches 1.. at @s rotated ~$(a) 0 positioned ^1.3 ^1.0 ^0 run particle minecraft:sweep_attack ~ ~ ~ 0.04 0.04 0.04 0.0 1 normal
$execute if score @s zx.mq_soul matches 2.. at @s rotated ~$(a) 0 rotated ~72 0 positioned ^1.3 ^1.0 ^0 run particle minecraft:sweep_attack ~ ~ ~ 0.04 0.04 0.04 0.0 1 normal
$execute if score @s zx.mq_soul matches 3.. at @s rotated ~$(a) 0 rotated ~144 0 positioned ^1.3 ^1.0 ^0 run particle minecraft:sweep_attack ~ ~ ~ 0.04 0.04 0.04 0.0 1 normal
$execute if score @s zx.mq_soul matches 4.. at @s rotated ~$(a) 0 rotated ~216 0 positioned ^1.3 ^1.0 ^0 run particle minecraft:sweep_attack ~ ~ ~ 0.04 0.04 0.04 0.0 1 normal
$execute if score @s zx.mq_soul matches 5.. at @s rotated ~$(a) 0 rotated ~288 0 positioned ^1.3 ^1.0 ^0 run particle minecraft:sweep_attack ~ ~ ~ 0.04 0.04 0.04 0.0 1 normal
