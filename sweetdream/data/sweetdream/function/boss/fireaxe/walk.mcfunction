execute unless score @s sdbf.state matches 1 as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/walk/play_exclusive
scoreboard players set @s sdbf.state 1
execute unless score @s sdbf.phase matches 3 at @s run function sweetdream:boss/fireaxe/move {step:0.085,ground:1}
execute if score @s sdbf.phase matches 3 at @s run function sweetdream:boss/fireaxe/move {step:0.105,ground:1}
execute unless score @s sdbf.phase matches 3 if score @s sdbf.moved matches 0 at @s positioned ~ ~1 ~ run function sweetdream:boss/fireaxe/move {step:0.085,ground:1}
execute if score @s sdbf.phase matches 3 if score @s sdbf.moved matches 0 at @s positioned ~ ~1 ~ run function sweetdream:boss/fireaxe/move {step:0.105,ground:1}
execute if score @s sdbf.moved matches 0 rotated ~45 0 run function sweetdream:boss/fireaxe/move {step:0.06,ground:1}
execute if score @s sdbf.moved matches 0 rotated ~-45 0 run function sweetdream:boss/fireaxe/move {step:0.06,ground:1}
