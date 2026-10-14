data modify storage zx:anchor pick set value {i:0}
execute store result storage zx:anchor pick.i int 1 run scoreboard players get @s zx.av_t
function sweetdream:equipment/axe/anchor/visual/floor_get with storage zx:anchor pick
execute store result score #av_ground zx.meta run data get entity @s item.components."minecraft:custom_data".zx_an.ground_y 1000
scoreboard players operation #av_y zx.meta += #av_ground zx.meta
data modify storage zx:anchor aim set value {x:0.0d,y:0.0d,z:0.0d}
data modify storage zx:anchor aim.x set from entity @s Pos[0]
data modify storage zx:anchor aim.z set from entity @s Pos[2]
execute store result storage zx:anchor aim.y double 0.001 run scoreboard players get #av_y zx.meta
function sweetdream:equipment/axe/anchor/visual/floor_move with storage zx:anchor aim
