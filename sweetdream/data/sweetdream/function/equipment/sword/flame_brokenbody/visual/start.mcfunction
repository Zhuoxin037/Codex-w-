# cast 完成扣费与目标快照后进入；保存强化状态，后续在命中帧结算。
execute if entity @s[tag=zx.fb_cast] run function sweetdream:equipment/sword/flame_brokenbody/visual/end
scoreboard players operation @s zx.fb_mode = #fb_enh zx.meta
scoreboard players set @s zx.fb_frame 0
scoreboard players set @s zx.fb_hand 0
scoreboard players set @s zx.fb_slot 0
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["flame_brokenbody"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["flame_brokenbody"]}] run scoreboard players set @s zx.fb_hand 1
execute if score @s zx.fb_hand matches 0 store result score @s zx.fb_slot run data get entity @s SelectedItemSlot
function sweetdream:equipment/sword/flame_brokenbody/visual/dimension
scoreboard players operation @s zx.fb_dim = #fb_dimension zx.meta
scoreboard players operation @s zx.fb_until = #now manacore.meta
scoreboard players add @s zx.fb_until 45
tag @s add zx.fb_cast
