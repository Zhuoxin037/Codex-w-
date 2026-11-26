# Check the resolved victim in the caller's context before changing the executor to by.
scoreboard players set #target sd.floor 0
$execute as $(target) if entity @s[tag=sd.floor_enemy] run scoreboard players set #target sd.floor 1
$execute if score #target sd.floor matches 1 as $(by) if entity @s[tag=sd.floor_run] run function sweetdream_floor:combat/echo_record {mark:"$(mark)"}
