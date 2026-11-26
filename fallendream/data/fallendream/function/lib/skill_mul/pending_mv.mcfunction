scoreboard players set #mv_panel zx.meta 20
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"],ol:"mottle_vein"}] run scoreboard players set #mv_panel zx.meta 25
scoreboard players set #mv_pan_n zx.meta 0
execute if entity @s[tag=zx.mv_ny] run scoreboard players add #mv_pan_n zx.meta 1
execute if entity @s[tag=zx.mv_ny2] run scoreboard players add #mv_pan_n zx.meta 1
scoreboard players operation #mv_panel zx.meta *= #mv_pan_n zx.meta
execute store result storage zx:work put.pct int 1 run scoreboard players get #mv_panel zx.meta
function fallendream:lib/dmg_add_put_any
