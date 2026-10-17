scoreboard players operation #bv_pose zx.meta = @s zx.bv_age
execute if score @s zx.bv_back matches 1 if score @s zx.bv_age matches 17.. run scoreboard players operation #bv_pose zx.meta = #now manacore.meta
scoreboard players set #bv_cycle zx.meta 80
scoreboard players set #bv_two zx.meta 2
execute if score @s zx.bv_back matches 1 if score @s zx.bv_age matches 17.. run scoreboard players operation #bv_pose zx.meta %= #bv_cycle zx.meta
execute if score @s zx.bv_back matches 1 if score @s zx.bv_age matches 17.. run scoreboard players operation #bv_pose zx.meta /= #bv_two zx.meta
execute if score @s zx.bv_back matches 1 if score @s zx.bv_age matches 17.. run scoreboard players add #bv_pose zx.meta 100
execute if score @s zx.bv_back matches 1 if score @s zx.bv_age matches 17.. if score @s zx.bv_t matches 1..15 run scoreboard players operation #bv_pose zx.meta = @s zx.bv_t
execute if score @s zx.bv_back matches 1 if score @s zx.bv_age matches 17.. if score @s zx.bv_t matches 1..15 run scoreboard players add #bv_pose zx.meta 199
execute if score @s zx.bv_back matches 2 run scoreboard players add #bv_pose zx.meta 300
scoreboard players add @s zx.bv_age 1
