scoreboard players set @s sdbf.state 2
scoreboard players set @s sdbf.age 0
scoreboard players set @s sdbf.blocked 0
execute unless score @s sdbf.phase matches 3 as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/attack/play_exclusive
execute if score @s sdbf.phase matches 3 as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/p2_attack/play_exclusive
playsound minecraft:entity.ravager.ambient hostile @a[distance=..24] ~ ~ ~ 0.55 0.75
