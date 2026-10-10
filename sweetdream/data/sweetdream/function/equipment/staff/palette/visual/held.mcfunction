scoreboard players add @s zx.pv_idle 1
execute if score @s zx.pv_idle matches 80.. run scoreboard players set @s zx.pv_idle 0
scoreboard players operation #frame zx.pv_f = @s zx.pv_idle
scoreboard players operation #frame zx.pv_f /= #4 zx.pv_f
scoreboard players set #c1 zx.pv_f 0
scoreboard players set #c2 zx.pv_f 0
execute if score @s zx.pal_c1 matches 1..3 run scoreboard players operation #c1 zx.pv_f = @s zx.pal_c1
execute if score @s zx.pal_c2 matches 1..3 run scoreboard players operation #c2 zx.pv_f = @s zx.pal_c2
execute if score @s zx.pv_age matches 0..31 run scoreboard players operation #frame zx.pv_f = @s zx.pv_age
execute if score @s zx.pv_age matches 0..31 run scoreboard players add #frame zx.pv_f 100
execute if score @s zx.pv_age matches 0..31 run scoreboard players operation #c1 zx.pv_f = @s zx.pv_c1
execute if score @s zx.pv_age matches 0..31 run scoreboard players operation #c2 zx.pv_f = @s zx.pv_c2
scoreboard players set #empty zx.pv_f 0
execute if score #c1 zx.pv_f matches 0 if score #c2 zx.pv_f matches 0 run scoreboard players set #empty zx.pv_f 1
data modify storage zx:work palette_visual set value {frame:0,c1:0,c2:0,empty:0}
execute store result storage zx:work palette_visual.frame int 1 run scoreboard players get #frame zx.pv_f
execute store result storage zx:work palette_visual.c1 int 1 run scoreboard players get #c1 zx.pv_f
execute store result storage zx:work palette_visual.c2 int 1 run scoreboard players get #c2 zx.pv_f
execute store result storage zx:work palette_visual.empty int 1 run scoreboard players get #empty zx.pv_f
function sweetdream:equipment/staff/palette/visual/apply with storage zx:work palette_visual
