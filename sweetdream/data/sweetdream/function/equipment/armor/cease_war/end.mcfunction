execute if entity @s[tag=zx.s2_cw] run attribute @s minecraft:armor modifier remove sweetdream:cease_war
execute if entity @s[tag=zx.s2_cw] run attribute @s minecraft:knockback_resistance modifier remove sweetdream:cease_war
tag @s remove zx.s2_cw
scoreboard players set @s zx.s2_cw_end 0
