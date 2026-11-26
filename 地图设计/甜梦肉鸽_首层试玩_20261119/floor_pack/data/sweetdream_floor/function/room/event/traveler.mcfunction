tellraw @s {"text":"旅人的遗物","color":"light_purple"}
tellraw @s {"text":"旧背囊挂在墙上。夹层里压着纸条：带上你路上用得着的。","color":"gray"}
tellraw @s [{"text":"[拿走钱袋]","color":"gold","click_event":{"action":"run_command","command":"/trigger sd.floor_cmd set 20"}},{"text":"  获得 2 梦屑","color":"gray"}]
tellraw @s [{"text":"[解开包裹]","color":"gold","click_event":{"action":"run_command","command":"/trigger sd.floor_cmd set 21"}},{"text":"  获得 2 颗金苹果","color":"gray"}]
