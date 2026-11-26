execute unless entity @a[tag=sd.floor_tutorial,distance=..25] run return run function sweetdream_floor:tutorial/stage/sleep
execute unless loaded -89 90 48 run return 0
execute unless loaded -103 90 44 run return 0
execute unless data storage sweetdream_floor:run {demonstration:4b} run function sweetdream_floor:tutorial/stage/build
execute unless score #edu_live sd.floor matches 1 run function sweetdream_floor:tutorial/stage/wake
function sweetdream_floor:tutorial/stage/buttons
execute if score #edu_live sd.floor matches 1 run function sweetdream_floor:tutorial/stage/animate
