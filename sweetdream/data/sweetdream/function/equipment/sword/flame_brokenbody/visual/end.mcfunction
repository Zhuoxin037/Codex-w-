# 复位消耗时的原槽，换栏不会把刀留在半挥状态。宏槽位必须始终合法0..8。
data modify storage zx:fbvis reset set value {slot:0}
execute if score @s zx.fb_slot matches 0..8 store result storage zx:fbvis reset.slot int 1 run scoreboard players get @s zx.fb_slot
execute if score @s zx.fb_hand matches 0 run function sweetdream:equipment/sword/flame_brokenbody/visual/reset_slot with storage zx:fbvis reset
execute if score @s zx.fb_hand matches 1 if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["flame_brokenbody"]}] if data entity @s equipment.offhand.components."minecraft:custom_model_data".floats[1] run item modify entity @s weapon.offhand sweetdream:flame_cast/idle
# 强化已经打出一斩再取消也要清熔浆，避免中断第三段保留强化反复使用。
execute if score @s zx.fb_mode matches 1 if score @s zx.fb_frame matches 8.. run scoreboard players set @s zx.fb_lava 0
tag @s remove zx.fb_cast
scoreboard players reset @s zx.fb_frame
scoreboard players reset @s zx.fb_mode
scoreboard players reset @s zx.fb_hand
scoreboard players reset @s zx.fb_slot
scoreboard players reset @s zx.fb_until
scoreboard players reset @s zx.fb_dim
function sweetdream:lib/uuid
data modify storage zx:fbvis clear set value {uuid:""}
data modify storage zx:fbvis clear.uuid set from storage zx:data self.uuid
execute if data storage zx:data self{ok:1b} run function sweetdream:equipment/sword/flame_brokenbody/visual/clear_owned with storage zx:fbvis clear

# 取消动作同时取消尚未命中的阶段与本人的目标记录。
function sweetdream:equipment/sword/flame_brokenbody/combat/context
function sweetdream:equipment/sword/flame_brokenbody/combat/forget with storage zx:fbcombat ctx
scoreboard players reset @s zx.fb_ol
scoreboard players reset @s zx.fb_refresh
