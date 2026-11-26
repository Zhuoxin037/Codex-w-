scoreboard players set #phase sd.floor 4
title @s title {"text":"首层通关","color":"aqua"}
tellraw @s [{"text":"神格三选一。领取后可以在本层试用，再返回大厅。","color":"gray"}]
tellraw @s [{"text":"[觉醒] ","color":"aqua","click_event":{"action":"run_command","command":"/trigger sd.floor_cmd set 40"}},{"text":"觉醒当前职业。“我”获得 2 分钟力量。","color":"gray"}]
tellraw @s [{"text":"[深井] ","color":"aqua","click_event":{"action":"run_command","command":"/trigger sd.floor_cmd set 41"}},{"text":"回满魔力，并立即清掉已登记的技能冷却。","color":"gray"}]
tellraw @s [{"text":"[饱梦] ","color":"aqua","click_event":{"action":"run_command","command":"/trigger sd.floor_cmd set 42"}},{"text":"获得两颗金苹果与生命恢复。","color":"gray"}]
