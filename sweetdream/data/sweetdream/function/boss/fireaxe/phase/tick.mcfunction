execute unless entity @s[nbt={Invulnerable:1b}] run data modify entity @s Invulnerable set value 1b
execute store result score @s sdbf.frame run scoreboard players get @e[tag=sd.fb.current_rig,limit=1,distance=0..] sweetdream_boss.reconstruction.phase_roar.frame
execute if score @s sdbf.frame matches 13 run playsound minecraft:block.anvil.land hostile @a[distance=..32] ~ ~ ~ 0.45 0.65
execute if score @s sdbf.frame matches 13 run particle minecraft:poof ~ ~0.1 ~ 0.65 0.05 0.65 0.03 16 normal
execute if score @s sdbf.frame matches 64.. run return run function sweetdream:boss/fireaxe/phase/end
execute if score @s sdbf.age matches 90.. run return run function sweetdream:boss/fireaxe/phase/end
execute unless entity @e[tag=sd.fb.current_rig,limit=1,distance=0..,tag=sweetdream_boss.reconstruction.animation.phase_roar.playing] run function sweetdream:boss/fireaxe/phase/end
