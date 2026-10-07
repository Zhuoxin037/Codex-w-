# 帧号按玩家独立保存；未拿书也继续收尾，避免切物品后卡在施法姿态。
execute if entity @s[nbt={Health:0.0f}] run return run function sweetdream:equipment/staff/apocalypse/visual/cancel
execute unless score @s zx.ap_on matches 1.. unless score @s zx.apv matches 259..274 run function sweetdream:equipment/staff/apocalypse/visual/end
scoreboard players operation #old zx.apv = @s zx.apv
execute if score #old zx.apv matches 99..136 run scoreboard players add @s zx.apv 1
execute if score #old zx.apv matches 137 run scoreboard players set @s zx.apv 150
execute if score #old zx.apv matches 159..177 run scoreboard players add @s zx.apv 1
execute if score #old zx.apv matches 178 run scoreboard players set @s zx.apv 150
execute if score #old zx.apv matches 199..210 run scoreboard players add @s zx.apv 1
execute if score #old zx.apv matches 211 run scoreboard players set @s zx.apv 150
execute if score #old zx.apv matches 219..246 run scoreboard players add @s zx.apv 1
execute if score #old zx.apv matches 247 run scoreboard players set @s zx.apv 150
execute if score #old zx.apv matches 259..273 run scoreboard players add @s zx.apv 1
execute if score #old zx.apv matches 274 run function sweetdream:equipment/staff/apocalypse/visual/cancel
# 无启示页不播放记页疾翻、也不会有灾示脉冲。
execute if score @s zx.apvc matches 0 if score @s zx.apv matches 110..137 run scoreboard players set @s zx.apv 150
