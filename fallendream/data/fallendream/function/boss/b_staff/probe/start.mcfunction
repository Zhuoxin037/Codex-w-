summon minecraft:marker ~ ~ ~ {Tags:["sd.bs.probe"]}
data modify entity @e[tag=sd.bs.probe,distance=..0.01,limit=1] Rotation set from entity @s Rotation
scoreboard players set @e[tag=sd.bs.probe,distance=..0.01,limit=1] bs.path 1
execute as @e[tag=sd.bs.probe,distance=..0.01,limit=1] at @s run function fallendream:boss/b_staff/probe/run
scoreboard players operation @s bs.path = @e[tag=sd.bs.probe,distance=0..,limit=1] bs.path
kill @e[tag=sd.bs.probe,distance=0..]
