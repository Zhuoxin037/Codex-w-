execute if entity @s[tag=zx.tv_cast] run function sweetdream:equipment/staff/triad/visual/end
function sweetdream:equipment/staff/triad/visual/model_sync
scoreboard players set @s zx.tv_hand 0
scoreboard players set @s zx.tv_slot 0
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["triad"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["triad"]}] run scoreboard players set @s zx.tv_hand 1
execute if entity @s[tag=test_pending_return] run scoreboard players set @s zx.tv_hand 0
execute if entity @s[tag=test_pending_return] if score @s zx.ret_slot matches -1 run scoreboard players set @s zx.tv_hand 1
execute if score @s zx.tv_hand matches 0 store result score @s zx.tv_slot run data get entity @s SelectedItemSlot
execute if entity @s[tag=test_pending_return] if score @s zx.ret_slot matches 0..8 run scoreboard players operation @s zx.tv_slot = @s zx.ret_slot
scoreboard players set @s zx.tv_form 0
execute if score @s zx.tri_form matches 1..2 run scoreboard players operation @s zx.tv_form = @s zx.tri_form
scoreboard players set @s zx.tv_t 1
tag @s add zx.tv_cast
execute if entity @s[tag=test_pending_return] run tag @s add zx.tv_pending
scoreboard players set #tv_pose zx.meta 1
execute unless entity @s[tag=test_pending_return] run function sweetdream:equipment/staff/triad/visual/set_frame
