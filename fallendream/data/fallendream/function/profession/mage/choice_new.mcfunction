summon minecraft:text_display ~ ~ ~ {Tags:["zx.j_choice_new","zx.j_choice"],text:{text:"？",color:"light_purple"},billboard:"center",background:0,see_through:0b,view_range:8.0f}
data modify entity @e[tag=zx.j_choice_new,limit=1] data.owner set from storage zx:data self.uuid
scoreboard players set @e[tag=zx.j_choice_new,limit=1] zx.j_life 120
tag @e[tag=zx.j_choice_new] remove zx.j_choice_new
