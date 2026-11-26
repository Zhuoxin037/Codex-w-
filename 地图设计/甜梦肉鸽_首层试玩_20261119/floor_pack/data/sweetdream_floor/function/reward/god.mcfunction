scoreboard players set #phase sd.floor 5
execute if score #input sd.floor matches 40 unless score @s zx.job matches 0 run function sweetdream:profession/awaken
execute if score #input sd.floor matches 40 if score @s zx.job matches 0 run effect give @s minecraft:strength 120 0 true
execute if score #input sd.floor matches 41 run function sweetdream_floor:run/reset_cooldowns
execute if score #input sd.floor matches 41 run function sweetdream_floor:run/mana {value:100000.0}
execute if score #input sd.floor matches 42 run give @s minecraft:golden_apple 2
execute if score #input sd.floor matches 42 run function sweetdream_floor:run/refill
tellraw @s [{"text":"试做层已通关。 ","color":"gray"},{"text":"[返回等待大厅]","color":"gold","click_event":{"action":"run_command","command":"/trigger sd.floor_cmd set 3"}}]
