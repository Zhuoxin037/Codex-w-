# 返汐每10刻采样8格内渊海生物的位移；位移超过0.8格留下5秒海浪，已有海浪保留各自寿命。
execute if score @s zx.et_sa > #now manacore.meta run return 0
scoreboard players operation @s zx.et_sa = #now manacore.meta
scoreboard players operation @s zx.et_sa += #10 manacore.meta
execute as @e[type=!#sweetdream:no_damage,distance=..8,tag=zx.status.yuanhai] at @s run function sweetdream:equipment/armor/ebb_tide/sample_one
