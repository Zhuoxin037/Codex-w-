function sweetdream_floor:tutorial/stage/clear_actors
function sweetdream_floor:tutorial/stage/cue {line:"",color:"gray"}
scoreboard players set #edu_frame sd.floor 0
execute store result storage sweetdream_floor:tutorial scene.page int 1 run scoreboard players get #edu_page sd.floor
function sweetdream_floor:tutorial/stage/page_go with storage sweetdream_floor:tutorial scene
playsound minecraft:block.note_block.chime block @a[tag=sd.floor_tutorial,distance=..18] ~ ~ ~ 0.45 1.4
