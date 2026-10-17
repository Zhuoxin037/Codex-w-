execute unless score @s zx.bv_t matches 0.. run scoreboard players set @s zx.bv_t 16
scoreboard players add @s zx.bv_charge 0
scoreboard players operation #bv_pose zx.meta = #now manacore.meta
scoreboard players set #bv_two zx.meta 2
scoreboard players set #bv_forty zx.meta 40
scoreboard players operation #bv_pose zx.meta /= #bv_two zx.meta
scoreboard players operation #bv_pose zx.meta %= #bv_forty zx.meta
execute if predicate sweetdream:burst_dawn_using run scoreboard players add @s zx.bv_charge 1
execute unless predicate sweetdream:burst_dawn_using run scoreboard players set @s zx.bv_charge 0
execute if score @s zx.bv_charge matches 1.. run function sweetdream:equipment/bow/burst_dawn/visual/charge_pose
execute if data entity @s SelectedItem.components."minecraft:charged_projectiles"[0] run scoreboard players set #bv_pose zx.meta 112
execute if score @s zx.bv_t matches 0..15 run scoreboard players operation #bv_pose zx.meta = @s zx.bv_t
execute if score @s zx.bv_t matches 0..15 run scoreboard players add #bv_pose zx.meta 200
execute if score @s zx.bv_t matches 0..15 run scoreboard players add @s zx.bv_t 1
execute if items entity @s weapon.mainhand *[custom_data~{zx:["burst_dawn"]}] run function sweetdream:equipment/bow/burst_dawn/visual/hand_main
execute if items entity @s weapon.offhand *[custom_data~{zx:["burst_dawn"]}] run function sweetdream:equipment/bow/burst_dawn/visual/hand_off
