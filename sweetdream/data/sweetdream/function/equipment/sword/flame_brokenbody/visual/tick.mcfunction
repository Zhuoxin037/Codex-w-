# @s=玩家，core/tick 已 at @s；每刻一次，正常19帧，强化32帧。
execute unless score @s zx.fb_frame matches 0..31 run return run function sweetdream:equipment/sword/flame_brokenbody/visual/end
execute if entity @s[nbt={Health:0.0f}] run return run function sweetdream:equipment/sword/flame_brokenbody/visual/end
execute if score @s zx.fb_until <= #now manacore.meta run return run function sweetdream:equipment/sword/flame_brokenbody/visual/end
function sweetdream:equipment/sword/flame_brokenbody/visual/dimension
execute unless score @s zx.fb_dim = #fb_dimension zx.meta run return run function sweetdream:equipment/sword/flame_brokenbody/visual/end
# 回手事务未完成时暂停姿态，避免把其他物品写坏；45刻上限避免卡住。
execute if entity @s[tag=test_pending_return] run return 0
execute if score @s zx.fb_hand matches 0 store result score #fb_slot zx.meta run data get entity @s SelectedItemSlot
execute if score @s zx.fb_hand matches 0 unless score @s zx.fb_slot = #fb_slot zx.meta run return run function sweetdream:equipment/sword/flame_brokenbody/visual/end
execute if score @s zx.fb_hand matches 0 unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["flame_brokenbody"]}] run return run function sweetdream:equipment/sword/flame_brokenbody/visual/end
execute if score @s zx.fb_hand matches 1 unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["flame_brokenbody"]}] run return run function sweetdream:equipment/sword/flame_brokenbody/visual/end
execute if score @s zx.fb_frame matches 0 run function sweetdream:equipment/sword/flame_brokenbody/visual/prepare
scoreboard players operation #fb_pose zx.meta = @s zx.fb_frame
execute if score @s zx.fb_mode matches 0 run scoreboard players add #fb_pose zx.meta 100
execute if score @s zx.fb_mode matches 1 run scoreboard players add #fb_pose zx.meta 200
execute if score @s zx.fb_hand matches 0 run item modify entity @s weapon.mainhand sweetdream:flame_cast/frame
execute if score @s zx.fb_hand matches 1 run item modify entity @s weapon.offhand sweetdream:flame_cast/frame
function sweetdream:equipment/sword/flame_brokenbody/visual/particles
execute if score @s zx.fb_mode matches 1 if score @s zx.fb_frame matches 16 run function sweetdream:equipment/sword/flame_brokenbody/visual/fx_spawn
# 姿态先写入，再在当前动画帧命中；没有 schedule 或释放瞬间的抢跑伤害。
execute if score @s zx.fb_frame matches 7 run function sweetdream:equipment/sword/flame_brokenbody/combat/first
execute if score @s zx.fb_mode matches 1 if score @s zx.fb_frame matches 13 run function sweetdream:equipment/sword/flame_brokenbody/combat/second
execute if score @s zx.fb_mode matches 1 if score @s zx.fb_frame matches 20 run function sweetdream:equipment/sword/flame_brokenbody/combat/ring
scoreboard players add @s zx.fb_frame 1
execute if score @s zx.fb_mode matches 0 if score @s zx.fb_frame matches 19.. run function sweetdream:equipment/sword/flame_brokenbody/visual/end
execute if score @s zx.fb_mode matches 1 if score @s zx.fb_frame matches 32.. run function sweetdream:equipment/sword/flame_brokenbody/visual/end
