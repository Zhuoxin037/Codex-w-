function sweetdream:lib/uuid
data modify storage zx:work owner_arg set from storage zx:data self
execute if data storage zx:data self{ok:1b} run function sweetdream:equipment/sword/way_back/end_go with storage zx:work owner_arg
scoreboard players reset @s zx.wb_on
scoreboard players reset @s zx.wb_t
scoreboard players reset @s zx.wb_dmg
scoreboard players reset @s zx.wb_low
