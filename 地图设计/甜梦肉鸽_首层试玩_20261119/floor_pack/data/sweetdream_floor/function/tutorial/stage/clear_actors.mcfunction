function sweetdream:tag/unmark {target:"@e[tag=sd.edu_target,distance=..25]",mark:"yuanhai"}
execute as @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25] run data remove entity @s equipment
function sweetdream_floor:tutorial/stage/remove_hidden {actors:"@e[tag=sd.edu_actor,distance=..25]"}
