scoreboard players remove @s zx.hv_t 1
execute if score @s zx.hv_t matches ..0 run return run function sweetdream:equipment/armor/heart_vein/pump_end
execute unless score @s zx.hv_path_v matches 1 run function sweetdream:equipment/armor/heart_vein/path_init
execute store result score #hv_cx zx.meta run data get entity @s Pos[0] 64
execute store result score #hv_cy zx.meta run data get entity @s Pos[1] 64
execute store result score #hv_cz zx.meta run data get entity @s Pos[2] 64
scoreboard players operation #hv_dx zx.meta = #hv_cx zx.meta
scoreboard players operation #hv_dx zx.meta -= @s zx.hv_px
scoreboard players operation #hv_dy zx.meta = #hv_cy zx.meta
scoreboard players operation #hv_dy zx.meta -= @s zx.hv_py
scoreboard players operation #hv_dz zx.meta = #hv_cz zx.meta
scoreboard players operation #hv_dz zx.meta -= @s zx.hv_pz
scoreboard players operation @s zx.hv_px = #hv_cx zx.meta
scoreboard players operation @s zx.hv_py = #hv_cy zx.meta
scoreboard players operation @s zx.hv_pz = #hv_cz zx.meta
execute if score #hv_dx zx.meta matches 20000.. run scoreboard players set #hv_dx zx.meta 20000
execute if score #hv_dx zx.meta matches ..-20000 run scoreboard players set #hv_dx zx.meta -20000
execute if score #hv_dy zx.meta matches 20000.. run scoreboard players set #hv_dy zx.meta 20000
execute if score #hv_dy zx.meta matches ..-20000 run scoreboard players set #hv_dy zx.meta -20000
execute if score #hv_dz zx.meta matches 20000.. run scoreboard players set #hv_dz zx.meta 20000
execute if score #hv_dz zx.meta matches ..-20000 run scoreboard players set #hv_dz zx.meta -20000
scoreboard players operation #sq_n zx.meta = #hv_dx zx.meta
scoreboard players operation #sq_n zx.meta *= #hv_dx zx.meta
scoreboard players operation #hv_dt zx.meta = #hv_dy zx.meta
scoreboard players operation #hv_dt zx.meta *= #hv_dy zx.meta
scoreboard players operation #sq_n zx.meta += #hv_dt zx.meta
scoreboard players operation #hv_dt zx.meta = #hv_dz zx.meta
scoreboard players operation #hv_dt zx.meta *= #hv_dz zx.meta
scoreboard players operation #sq_n zx.meta += #hv_dt zx.meta
function sweetdream:lib/math/isqrt
scoreboard players add @s zx.hv_walk 0
scoreboard players operation @s zx.hv_walk += #sq_out zx.meta
execute if score @s zx.hv_walk matches 64.. run function sweetdream:equipment/armor/heart_vein/path_steps
