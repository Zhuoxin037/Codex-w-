# 0 不参与驱动；换槽/换形态/离手时只结束视觉。
execute unless score @s zx.tv_t matches 1.. run return run function sweetdream:equipment/staff/triad/visual/end
scoreboard players set #tv_form zx.meta 0
execute if score @s zx.tri_form matches 1..2 run scoreboard players operation #tv_form zx.meta = @s zx.tri_form
execute unless score @s zx.tv_form = #tv_form zx.meta run return run function sweetdream:equipment/staff/triad/visual/end
scoreboard players set #tv_slot zx.meta -1
execute if score @s zx.tv_hand matches 0 store result score #tv_slot zx.meta run data get entity @s SelectedItemSlot
execute if score @s zx.tv_hand matches 0 unless score @s zx.tv_slot = #tv_slot zx.meta run return run function sweetdream:equipment/staff/triad/visual/end
execute if score @s zx.tv_hand matches 0 unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["triad"]}] run return run function sweetdream:equipment/staff/triad/visual/end
execute if score @s zx.tv_hand matches 1 unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["triad"]}] run return run function sweetdream:equipment/staff/triad/visual/end
execute if entity @s[tag=zx.tv_pending] run return run function sweetdream:equipment/staff/triad/visual/first_return
scoreboard players add @s zx.tv_t 1
execute if score @s zx.tv_t matches 10.. run return run function sweetdream:equipment/staff/triad/visual/end
scoreboard players operation #tv_pose zx.meta = @s zx.tv_t
function sweetdream:equipment/staff/triad/visual/set_frame
