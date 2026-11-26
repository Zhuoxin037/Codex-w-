execute if data storage sweetdream_floor:run inspected{kind:"entry"} run return 0
$execute positioned $(x) 81 $(z) unless entity @s[distance=..8] run return run tellraw @s {"text":"走到房间中部再布置寄存箱。","color":"gray"}
$setblock $(px) 81 $(pz) minecraft:ender_chest[facing=north]
tellraw @s {"text":"已在本房东南侧放置寄存箱。","color":"green"}
