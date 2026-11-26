function sweetdream_floor:combat/clean
function sweetdream_floor:combat/open_doors
execute if data storage sweetdream_floor:run current{kind:"boss"} run function sweetdream_floor:room/unmark with storage sweetdream_floor:run current
scoreboard players set #phase sd.floor 1
tellraw @s {"text":"撤出房间，战斗结束。","color":"red"}
