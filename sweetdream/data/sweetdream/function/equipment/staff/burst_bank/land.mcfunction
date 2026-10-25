# 刻末地形若改变而失去支撑，回原点并按实际主人退款。
scoreboard players set @s zx.bb_on 0
execute if block ~ ~-0.01 ~ #minecraft:replaceable run function sweetdream:equipment/staff/burst_bank/fallback with storage zx:work bb
execute at @s run function sweetdream:equipment/staff/burst_bank/finish with storage zx:work bb
