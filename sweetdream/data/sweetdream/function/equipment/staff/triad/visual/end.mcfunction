# 恢复记录的原快捷栏槽；不把别的物品覆盖回手上。
data modify storage zx:triad_visual reset set value {slot:0}
execute if score @s zx.tv_slot matches 0..8 store result storage zx:triad_visual reset.slot int 1 run scoreboard players get @s zx.tv_slot
execute if score @s zx.tv_hand matches 0 run function sweetdream:equipment/staff/triad/visual/reset_slot with storage zx:triad_visual reset
execute if score @s zx.tv_hand matches 1 if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["triad"]}] run item modify entity @s weapon.offhand sweetdream:triad_visual/idle
tag @s remove zx.tv_cast
tag @s remove zx.tv_pending
scoreboard players set @s zx.tv_t 0
