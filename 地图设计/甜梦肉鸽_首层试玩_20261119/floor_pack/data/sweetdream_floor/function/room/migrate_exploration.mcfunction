# Reopening a floor from before exploration limits should respect its mapped rooms.
scoreboard players set #room_anchor sd.floor 10
scoreboard players set #budget sd.floor 8
scoreboard players set #already_explored sd.floor 0
execute store result score #already_explored sd.floor if data storage zx:rogue floor.cells[{present:1b,visited:1b}]
execute if data storage zx:rogue floor.cells[{kind:"entry",visited:1b}] run scoreboard players remove #already_explored sd.floor 1
execute if data storage zx:rogue floor.cells[{kind:"boss",visited:1b}] run scoreboard players remove #already_explored sd.floor 1
scoreboard players operation #budget sd.floor -= #already_explored sd.floor
execute if score #budget sd.floor matches ..-1 run scoreboard players set #budget sd.floor 0
data modify storage sweetdream_floor:run exploration set value 1b
