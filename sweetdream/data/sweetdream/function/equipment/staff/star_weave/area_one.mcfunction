execute store result score #weave_px zx.meta run data get entity @s Pos[0] 10
execute store result score #weave_py zx.meta run data get entity @s Pos[1] 10
execute store result score #weave_pz zx.meta run data get entity @s Pos[2] 10
scoreboard players set #weave_height zx.meta 0
scoreboard players operation #weave_y zx.meta = #weave_py zx.meta
scoreboard players operation #weave_y zx.meta -= #weave_ay zx.meta
execute if score #weave_y zx.meta matches -30..30 run scoreboard players set #weave_height zx.meta 1
scoreboard players operation #weave_y zx.meta = #weave_py zx.meta
scoreboard players operation #weave_y zx.meta -= #weave_by zx.meta
execute if score #weave_y zx.meta matches -30..30 run scoreboard players set #weave_height zx.meta 1
scoreboard players operation #weave_y zx.meta = #weave_py zx.meta
scoreboard players operation #weave_y zx.meta -= #weave_cy zx.meta
execute if score #weave_y zx.meta matches -30..30 run scoreboard players set #weave_height zx.meta 1
execute unless score #weave_height zx.meta matches 1 run return 0
scoreboard players operation #weave_dx zx.meta = #weave_px zx.meta
scoreboard players operation #weave_dx zx.meta -= #weave_ax zx.meta
scoreboard players operation #weave_dz zx.meta = #weave_pz zx.meta
scoreboard players operation #weave_dz zx.meta -= #weave_az zx.meta
scoreboard players operation #weave_cross1 zx.meta = #weave_abx zx.meta
scoreboard players operation #weave_cross1 zx.meta *= #weave_dz zx.meta
scoreboard players operation #weave_tmp zx.meta = #weave_abz zx.meta
scoreboard players operation #weave_tmp zx.meta *= #weave_dx zx.meta
scoreboard players operation #weave_cross1 zx.meta -= #weave_tmp zx.meta
scoreboard players operation #weave_dx zx.meta = #weave_px zx.meta
scoreboard players operation #weave_dx zx.meta -= #weave_bx zx.meta
scoreboard players operation #weave_dz zx.meta = #weave_pz zx.meta
scoreboard players operation #weave_dz zx.meta -= #weave_bz zx.meta
scoreboard players operation #weave_cross2 zx.meta = #weave_bcx zx.meta
scoreboard players operation #weave_cross2 zx.meta *= #weave_dz zx.meta
scoreboard players operation #weave_tmp zx.meta = #weave_bcz zx.meta
scoreboard players operation #weave_tmp zx.meta *= #weave_dx zx.meta
scoreboard players operation #weave_cross2 zx.meta -= #weave_tmp zx.meta
scoreboard players operation #weave_dx zx.meta = #weave_px zx.meta
scoreboard players operation #weave_dx zx.meta -= #weave_cx zx.meta
scoreboard players operation #weave_dz zx.meta = #weave_pz zx.meta
scoreboard players operation #weave_dz zx.meta -= #weave_cz zx.meta
scoreboard players operation #weave_cross3 zx.meta = #weave_cax zx.meta
scoreboard players operation #weave_cross3 zx.meta *= #weave_dz zx.meta
scoreboard players operation #weave_tmp zx.meta = #weave_caz zx.meta
scoreboard players operation #weave_tmp zx.meta *= #weave_dx zx.meta
scoreboard players operation #weave_cross3 zx.meta -= #weave_tmp zx.meta
execute if score #weave_cross1 zx.meta matches 0.. if score #weave_cross2 zx.meta matches 0.. if score #weave_cross3 zx.meta matches 0.. run tag @s add zx.weave_area
execute if score #weave_cross1 zx.meta matches ..0 if score #weave_cross2 zx.meta matches ..0 if score #weave_cross3 zx.meta matches ..0 run tag @s add zx.weave_area
