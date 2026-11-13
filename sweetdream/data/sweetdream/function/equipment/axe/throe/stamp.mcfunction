# 技能管线已经乘过1.1；把其损失写入基线，观察器不重复加伤。
scoreboard players operation #pn_sid zx.meta = @s zx.sid
scoreboard players set #pn_hp zx.meta 0
scoreboard players set #pn_ab zx.meta 0
execute store result score #pn_hp zx.meta run data get entity @s Health 1000
execute store result score #pn_ab zx.meta run data get entity @s AbsorptionAmount 1000
execute as @e[type=minecraft:marker,tag=zx.pn_watch,distance=0..] if score @s zx.sid = #pn_sid zx.meta store result entity @s data.hp int 1 run scoreboard players get #pn_hp zx.meta
execute as @e[type=minecraft:marker,tag=zx.pn_watch,distance=0..] if score @s zx.sid = #pn_sid zx.meta store result entity @s data.ab int 1 run scoreboard players get #pn_ab zx.meta
