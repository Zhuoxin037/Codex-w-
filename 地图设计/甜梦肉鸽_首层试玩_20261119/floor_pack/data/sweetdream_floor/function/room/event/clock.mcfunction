tellraw @s {"text":"停摆的钟","color":"light_purple"}
tellraw @s {"text":"钟摆卡在半空。指针每倒退一格，刚用过的技能就响一声。","color":"gray"}
tellraw @s [{"text":"[拨回指针]","color":"gold","click_event":{"action":"run_command","command":"/trigger sd.floor_cmd set 20"}},{"text":"  清空技能冷却","color":"gray"}]
tellraw @s [{"text":"[拆下钟摆]","color":"gold","click_event":{"action":"run_command","command":"/trigger sd.floor_cmd set 21"}},{"text":"  获得硬化·α","color":"gray"}]
