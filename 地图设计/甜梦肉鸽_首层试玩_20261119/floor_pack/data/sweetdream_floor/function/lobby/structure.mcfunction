fill -67 89 36 -39 89 59 minecraft:deepslate_tiles
fill -65 89 38 -41 89 57 minecraft:polished_deepslate
fill -63 89 46 -41 89 50 minecraft:smooth_quartz
fill -67 90 36 -67 93 59 minecraft:polished_blackstone_bricks
fill -39 90 36 -39 93 59 minecraft:polished_blackstone_bricks
fill -67 90 36 -39 93 36 minecraft:polished_blackstone_bricks
fill -67 90 59 -39 93 59 minecraft:polished_blackstone_bricks
fill -66 91 36 -40 92 36 minecraft:cyan_stained_glass
fill -66 91 59 -40 92 59 minecraft:cyan_stained_glass
fill -58 89 39 -53 89 43 minecraft:oxidized_cut_copper
fill -58 89 53 -53 89 57 minecraft:amethyst_block
fill -58 89 44 -53 89 44 minecraft:sea_lantern
fill -58 89 52 -53 89 52 minecraft:pearlescent_froglight
fill -106 89 37 -78 89 59 minecraft:polished_deepslate
fill -104 89 39 -80 89 57 minecraft:smooth_quartz
fill -106 90 37 -78 91 37 minecraft:cyan_stained_glass
fill -106 90 59 -78 91 59 minecraft:cyan_stained_glass
fill -106 90 37 -106 91 59 minecraft:cyan_stained_glass
fill -78 90 37 -78 91 59 minecraft:cyan_stained_glass
fill -96 89 44 -87 89 53 minecraft:sea_lantern
fill -95 89 45 -88 89 52 minecraft:deepslate_tiles
summon minecraft:text_display -56 93 48 {Tags:["sd.floor_lobby_display"],billboard:"center",background:0,text:{text:"甜 梦 · 回 廊",bold:true,color:"aqua"},transformation:{translation:[0f,0f,0f],left_rotation:[0f,0f,0f,1f],scale:[2f,2f,2f],right_rotation:[0f,0f,0f,1f]}}
summon minecraft:text_display -55 91.6 41 {Tags:["sd.floor_lobby_display"],billboard:"center",background:0,text:{text:"开局 · 踏上铜台",color:"aqua"}}
summon minecraft:text_display -55 91.6 55 {Tags:["sd.floor_lobby_display"],billboard:"center",background:0,text:{text:"教程 · 踏上紫晶台",color:"light_purple"}}
summon minecraft:text_display -92 93 48 {Tags:["sd.floor_lobby_display"],billboard:"center",background:0,text:{text:"甜梦图书室 · 阅读与练习",color:"aqua"}}
setworldspawn -48 90 48 -90
gamerule spawnRadius 0
gamerule doMobSpawning false
gamerule keepInventory true
gamerule doImmediateRespawn true
gamerule doDaylightCycle false
time set noon
