# 返汐生成独立5秒海浪；不删除该生物先前留下的海浪，不设置文案以外的全场数量上限。
execute unless score @s zx.et_wid matches 1.. run scoreboard players add #et_wid zx.meta 1
execute unless score @s zx.et_wid matches 1.. run scoreboard players operation @s zx.et_wid = #et_wid zx.meta
scoreboard players operation #et_w zx.meta = @s zx.et_wid
summon minecraft:marker ~ ~ ~ {Tags:["zx.et_wave","zx.et_new"]}
scoreboard players set @e[tag=zx.et_new,limit=1] zx.et_life 100
scoreboard players operation @e[tag=zx.et_new,limit=1] zx.et_wid = #et_w zx.meta
execute as @e[tag=zx.et_new,limit=1] at @s run function sweetdream:equipment/visual/water/create {model:"sweetdream:ebb_wave",sx:2.0,sy:2.0,sz:2.0,life_obj:"zx.et_life",kind:"wave"}
tag @e[tag=zx.et_new,limit=1] remove zx.et_new
particle minecraft:splash ~ ~0.1 ~ 0.45 0.05 0.45 0.08 14
particle minecraft:bubble ~ ~0.1 ~ 0.45 0.05 0.45 0.02 8
