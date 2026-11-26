execute unless data storage sweetdream_floor:run {lobby:1b} run return 0
scoreboard players enable @a sd.floor_cmd
execute as @a[tag=!sd.floor_seen] at @s run function sweetdream_floor:lobby/first_join
execute if score #phase sd.floor matches 1.. unless entity @a[tag=sd.floor_run] run function sweetdream_floor:run/orphan
execute as @a[tag=sd.floor_run] at @s run function sweetdream_floor:run/player_tick
execute as @a[tag=!sd.floor_run] at @s run function sweetdream_floor:lobby/player_tick
execute as @a[scores={sd.floor_cmd=1..}] at @s run function sweetdream_floor:route
execute if entity @a[tag=sd.floor_tutorial] run return run function sweetdream_floor:tutorial/stage/tick
execute if score #edu_live sd.floor matches 1 run function sweetdream_floor:tutorial/stage/tick
