data modify storage zx:anchor reset set value {slot:0}
execute if score @s zx.av_slot matches 0..8 store result storage zx:anchor reset.slot int 1 run scoreboard players get @s zx.av_slot
execute if score @s zx.av_hand matches 0 run function sweetdream:equipment/axe/anchor/visual/reset_slot with storage zx:anchor reset
execute if score @s zx.av_hand matches 1 if items entity @s weapon.offhand diamond_axe[custom_data~{zx:["anchor"]}] if data entity @s equipment.offhand.components."minecraft:custom_model_data".floats[1] run item modify entity @s weapon.offhand sweetdream:anchor_visual/idle
tag @s remove zx.av_cast

# ★ 2026-10-23: 摘掉这一发挂在目标身上的"锁定"标签(按自己 UUID[0] 认, 别人的不动)。
#   不摘的话标签会一直留在那只怪身上 —— 虽然下游都带 scores 认人、不会串,
#   但场上会慢慢攒出一批空标签, /reload 之前一直挂着。
scoreboard players set #anc_u zx.meta 0
scoreboard players operation #anc_u zx.meta = @s manacore.u0
execute as @e[tag=zx.an_lock] if score @s zx.an_own = #anc_u zx.meta run tag @s remove zx.an_lock

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
