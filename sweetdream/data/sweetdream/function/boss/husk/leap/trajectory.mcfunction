execute store result score #start_x sdh.tmp run data get entity @e[tag=sd.hk.jump_start_now,distance=0..,limit=1] Pos[0] 64
execute store result score #end_x sdh.tmp run data get entity @e[tag=sd.hk.jump_end_now,distance=0..,limit=1] Pos[0] 64
scoreboard players operation #end_x sdh.tmp -= #start_x sdh.tmp
scoreboard players operation #end_x sdh.tmp *= @s sdh.age
scoreboard players operation #end_x sdh.tmp /= #16 sdh.tmp
scoreboard players operation #end_x sdh.tmp += #start_x sdh.tmp
execute store result score #start_y sdh.tmp run data get entity @e[tag=sd.hk.jump_start_now,distance=0..,limit=1] Pos[1] 64
execute store result score #end_y sdh.tmp run data get entity @e[tag=sd.hk.jump_end_now,distance=0..,limit=1] Pos[1] 64
scoreboard players operation #end_y sdh.tmp -= #start_y sdh.tmp
scoreboard players operation #end_y sdh.tmp *= @s sdh.age
scoreboard players operation #end_y sdh.tmp /= #16 sdh.tmp
scoreboard players operation #end_y sdh.tmp += #start_y sdh.tmp
execute store result score #start_z sdh.tmp run data get entity @e[tag=sd.hk.jump_start_now,distance=0..,limit=1] Pos[2] 64
execute store result score #end_z sdh.tmp run data get entity @e[tag=sd.hk.jump_end_now,distance=0..,limit=1] Pos[2] 64
scoreboard players operation #end_z sdh.tmp -= #start_z sdh.tmp
scoreboard players operation #end_z sdh.tmp *= @s sdh.age
scoreboard players operation #end_z sdh.tmp /= #16 sdh.tmp
scoreboard players operation #end_z sdh.tmp += #start_z sdh.tmp
execute if score @s sdh.age matches 1 run scoreboard players add #end_y sdh.tmp 30
execute if score @s sdh.age matches 2 run scoreboard players add #end_y sdh.tmp 56
execute if score @s sdh.age matches 3 run scoreboard players add #end_y sdh.tmp 78
execute if score @s sdh.age matches 4 run scoreboard players add #end_y sdh.tmp 96
execute if score @s sdh.age matches 5 run scoreboard players add #end_y sdh.tmp 110
execute if score @s sdh.age matches 6 run scoreboard players add #end_y sdh.tmp 120
execute if score @s sdh.age matches 7 run scoreboard players add #end_y sdh.tmp 126
execute if score @s sdh.age matches 8 run scoreboard players add #end_y sdh.tmp 128
execute if score @s sdh.age matches 9 run scoreboard players add #end_y sdh.tmp 126
execute if score @s sdh.age matches 10 run scoreboard players add #end_y sdh.tmp 120
execute if score @s sdh.age matches 11 run scoreboard players add #end_y sdh.tmp 110
execute if score @s sdh.age matches 12 run scoreboard players add #end_y sdh.tmp 96
execute if score @s sdh.age matches 13 run scoreboard players add #end_y sdh.tmp 78
execute if score @s sdh.age matches 14 run scoreboard players add #end_y sdh.tmp 56
execute if score @s sdh.age matches 15 run scoreboard players add #end_y sdh.tmp 30
execute if score @s sdh.age matches 16 run scoreboard players add #end_y sdh.tmp 0
execute store result score #current_x sdh.tmp run data get entity @s Pos[0] 64
scoreboard players operation #end_x sdh.tmp -= #current_x sdh.tmp
execute store result storage sweetdream:husk jump.x double 0.001953125 run scoreboard players get #end_x sdh.tmp
execute store result score #current_y sdh.tmp run data get entity @s Pos[1] 64
scoreboard players operation #end_y sdh.tmp -= #current_y sdh.tmp
execute store result storage sweetdream:husk jump.y double 0.001953125 run scoreboard players get #end_y sdh.tmp
execute store result score #current_z sdh.tmp run data get entity @s Pos[2] 64
scoreboard players operation #end_z sdh.tmp -= #current_z sdh.tmp
execute store result storage sweetdream:husk jump.z double 0.001953125 run scoreboard players get #end_z sdh.tmp
scoreboard players set @s sdh.jumpsteps 8
function sweetdream:boss/husk/leap/substep with storage sweetdream:husk jump
