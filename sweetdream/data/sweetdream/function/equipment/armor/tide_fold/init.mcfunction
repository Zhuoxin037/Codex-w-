execute unless data storage zx:geometry yaw run function sweetdream:lib/math/yaw_table
execute store result score #tf_angle zx.meta run data get entity @s Rotation[0]
scoreboard players set #tf_full zx.meta 360
scoreboard players operation #tf_angle zx.meta %= #tf_full zx.meta
execute store result storage zx:work tf_angle.i int 1 run scoreboard players get #tf_angle zx.meta
function sweetdream:equipment/armor/tide_fold/init_angle with storage zx:work tf_angle
execute store result score @s zx.tf_cx run data get entity @s Pos[0] 64
execute store result score @s zx.tf_cy run data get entity @s Pos[1] 64
execute store result score @s zx.tf_cz run data get entity @s Pos[2] 64
scoreboard players operation @s zx.tf_end = #now manacore.meta
scoreboard players add @s zx.tf_end 200
data modify entity @s data.cross set value {}

function sweetdream:equipment/visual/water/create {model:"sweetdream:tide_wall",sx:8.0,sy:5.0,sz:1.0,life_obj:"zx.tf_life",kind:"wall"}
