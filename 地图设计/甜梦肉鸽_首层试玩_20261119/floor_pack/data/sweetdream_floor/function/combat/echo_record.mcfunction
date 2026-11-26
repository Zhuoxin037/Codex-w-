scoreboard players add #echo sd.floor 1
$execute unless data storage sweetdream_floor:run echo_marks[{mark:"$(mark)"}] run scoreboard players add #echo_total sd.floor 1
$execute unless data storage sweetdream_floor:run echo_marks[{mark:"$(mark)"}] run data modify storage sweetdream_floor:run echo_marks append value {mark:"$(mark)"}
