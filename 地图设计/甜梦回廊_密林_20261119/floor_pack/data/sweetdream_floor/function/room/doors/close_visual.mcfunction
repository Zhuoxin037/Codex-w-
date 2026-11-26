$fill ~-$(x) ~ ~-$(z) ~$(x) ~4 ~$(z) minecraft:barrier replace minecraft:air
$execute positioned ~-$(x) ~ ~-$(z) run kill @e[type=minecraft:block_display,tag=sd.floor_gate,distance=..0.25]
$summon minecraft:block_display ~-$(x) ~ ~-$(z) {Tags:["sd.floor_gate","sd.floor_gate_new"],block_state:{Name:"minecraft:stripped_dark_oak_log",Properties:{axis:"$(axis)"}},transformation:{translation:[0.0f,5.0f,0.0f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f],scale:[$(sx).0f,5.0f,$(sz).0f]},width:8.0f,height:10.0f,view_range:1.5f}
