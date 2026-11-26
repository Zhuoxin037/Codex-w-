# Migration confined to the existing tutorial room. Lobby and dungeon blocks are separate.
execute positioned -92 93 48 run kill @e[type=minecraft:text_display,tag=sd.floor_lobby_display,distance=..1]
kill @e[type=minecraft:text_display,tag=sd.edu_layout,distance=..26]
fill -96 89 45 -87 89 45 minecraft:oxidized_cut_copper
fill -96 89 52 -87 89 52 minecraft:oxidized_cut_copper
execute if block -99 90 44 minecraft:lectern run setblock -99 90 44 minecraft:air
execute if block -100 90 47 minecraft:polished_blackstone_button run setblock -100 90 47 minecraft:air
setblock -100 90 46 minecraft:lectern[facing=west,has_book=true]
setblock -100 90 49 minecraft:polished_blackstone_button[face=floor,facing=east]
setblock -103 90 46 minecraft:stone_button[face=floor,facing=east]
execute if block -103 90 50 minecraft:stone_button run setblock -103 90 50 minecraft:air
function sweetdream_floor:tutorial/clear
summon minecraft:text_display -99.5 91.25 46.5 {Tags:["sd.edu_layout"],billboard:"center",background:0,text:{text:"右键读书",color:"aqua"}}
summon minecraft:text_display -92.2 93.25 48.5 {Tags:["sd.edu_layout","sd.edu_cue"],billboard:"center",background:0,line_width:210,text:{text:"",color:"aqua"}}
summon minecraft:text_display -99.5 90.85 49.5 {Tags:["sd.edu_layout"],billboard:"center",background:0,text:{text:"下一个",color:"aqua"}}
summon minecraft:text_display -102.5 90.85 46.5 {Tags:["sd.edu_layout"],billboard:"center",background:0,text:{text:"返回大厅",color:"gray"}}
data modify storage sweetdream_floor:run demonstration set value 4b
scoreboard players set #edu_live sd.floor 0
