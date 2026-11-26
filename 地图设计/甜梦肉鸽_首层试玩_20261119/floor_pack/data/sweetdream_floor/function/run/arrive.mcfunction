scoreboard players set #ready sd.floor 1
title @s times 5 26 15
title @s subtitle {"text":"探索 · 构筑 · 挑战坠梦骑士","color":"gray"}
title @s title {"text":"首层 · 梦核回廊","color":"aqua"}
playsound minecraft:block.amethyst_block.chime master @s ~ ~ ~ 0.9 0.8
setblock 6 81 54 minecraft:ender_chest[facing=north]
tellraw @s [{"text":"本层可探索 8 间新房。首次进入扣一次，走过的房间可以重走。按 9 查看层主位置。","color":"aqua"}]
tellraw @s [{"text":"每次开战最多携带三把武器；多余装备可放进寄存箱。 ","color":"gray"},{"text":"[状态 / 房间操作]","color":"green","click_event":{"action":"run_command","command":"/trigger sd.floor_cmd set 23"}}]
