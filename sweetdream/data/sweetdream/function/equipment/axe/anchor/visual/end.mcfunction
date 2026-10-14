data modify storage zx:anchor reset set value {slot:0}
execute if score @s zx.av_slot matches 0..8 store result storage zx:anchor reset.slot int 1 run scoreboard players get @s zx.av_slot
execute if score @s zx.av_hand matches 0 run function sweetdream:equipment/axe/anchor/visual/reset_slot with storage zx:anchor reset
execute if score @s zx.av_hand matches 1 if items entity @s weapon.offhand diamond_axe[custom_data~{zx:["anchor"]}] if data entity @s equipment.offhand.components."minecraft:custom_model_data".floats[1] run item modify entity @s weapon.offhand sweetdream:anchor_visual/idle
tag @s remove zx.av_cast

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:anchor key set value {uuid:""}
data modify storage zx:anchor key.uuid set from storage zx:data self.uuid

function sweetdream:equipment/axe/anchor/visual/clear_owned with storage zx:anchor key
scoreboard players reset @s zx.av_hand
scoreboard players reset @s zx.av_slot
scoreboard players reset @s zx.av_t
scoreboard players reset @s zx.av_phase
scoreboard players reset @s zx.av_dim
scoreboard players reset @s zx.av_life
