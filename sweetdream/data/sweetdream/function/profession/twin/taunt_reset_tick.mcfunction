scoreboard players remove @s zx.j_taunt_wait 1
execute if score @s zx.j_taunt_wait matches ..0 run attribute @s minecraft:follow_range modifier remove sweetdream:body_taunt_reset
execute if score @s zx.j_taunt_wait matches ..0 run tag @s remove zx.j_taunt_reset
