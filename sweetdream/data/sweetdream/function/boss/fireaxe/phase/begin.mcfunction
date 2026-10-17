scoreboard players set @s sdbf.phase 2
scoreboard players set @s sdbf.state 10
scoreboard players set @s sdbf.age 0
tag @s add sd.fb.transition
data modify entity @s Invulnerable set value 1b
execute as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/phase_roar/tween {duration:4,to_frame:0}
playsound minecraft:entity.ravager.roar hostile @a[distance=..32] ~ ~ ~ 1.0 0.72
