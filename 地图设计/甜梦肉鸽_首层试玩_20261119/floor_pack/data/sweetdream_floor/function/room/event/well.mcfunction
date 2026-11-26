tellraw @s {"text":"回声井","color":"light_purple"}
tellraw @s {"text":"井水一半映着你的伤口，一半映着熄灭的术纹。","color":"gray"}
tellraw @s [{"text":"[饮下井水]","color":"gold","click_event":{"action":"run_command","command":"/trigger sd.floor_cmd set 20"}},{"text":"  恢复生命","color":"gray"}]
tellraw @s [{"text":"[触碰术纹]","color":"gold","click_event":{"action":"run_command","command":"/trigger sd.floor_cmd set 21"}},{"text":"  回满魔力","color":"gray"}]
