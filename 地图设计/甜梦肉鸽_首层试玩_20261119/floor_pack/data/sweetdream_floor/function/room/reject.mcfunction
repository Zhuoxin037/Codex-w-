function sweetdream_floor:room/return_to_explored
tellraw @s [{"text":"探索次数用完了。可以重走旧房或 ","color":"gray"},{"text":"[前往层主]","color":"gold","click_event":{"action":"run_command","command":"/trigger sd.floor_cmd set 24"}}]
