scoreboard players set #edu_next sd.floor 1
scoreboard players add #edu_page sd.floor 1
execute if score #edu_page sd.floor matches 8.. run scoreboard players set #edu_page sd.floor 1
function sweetdream_floor:tutorial/stage/load_page
