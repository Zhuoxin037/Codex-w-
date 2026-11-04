tag @e[tag=zx.ws_in,distance=0..] remove zx.ws_in
tag @e[tag=zx.ws_target,distance=0..] remove zx.ws_target
execute store result score #wst_px zx.meta run data get entity @s Pos[0] 10
execute store result score #wst_pz zx.meta run data get entity @s Pos[2] 10
execute store result score #wst_px100 zx.meta run data get entity @s Pos[0] 100
execute store result score #wst_pz100 zx.meta run data get entity @s Pos[2] 100
execute rotated ~ 0 positioned ^ ^ ^1 run summon minecraft:marker ~ ~ ~ {Tags:["zx.ws_aim"]}
execute store result score #wst_fx zx.meta run data get entity @e[tag=zx.ws_aim,distance=0..,limit=1] Pos[0] 100
execute store result score #wst_fz zx.meta run data get entity @e[tag=zx.ws_aim,distance=0..,limit=1] Pos[2] 100
kill @e[tag=zx.ws_aim,distance=0..]
scoreboard players operation #wst_fx zx.meta -= #wst_px100 zx.meta
scoreboard players operation #wst_fz zx.meta -= #wst_pz100 zx.meta
scoreboard players operation #wst_norm zx.meta = #wst_fx zx.meta
scoreboard players operation #wst_norm zx.meta *= #wst_fx zx.meta
scoreboard players operation #wst_temp zx.meta = #wst_fz zx.meta
scoreboard players operation #wst_temp zx.meta *= #wst_fz zx.meta
scoreboard players operation #wst_norm zx.meta += #wst_temp zx.meta
execute as @e[type=!#sweetdream:no_damage,distance=..5] at @s run function sweetdream:equipment/sword/wound_stitch/cone_check
tag @e[tag=zx.ws_in,distance=..5,sort=nearest,limit=5] add zx.ws_target
tag @e[tag=zx.ws_in,distance=0..] remove zx.ws_in
