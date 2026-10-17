tag @s add sd.fb.dying
tag @s remove sd.fb.frozen
scoreboard players set @s sdbf.death_age 0
execute store result storage sweetdream:fireaxe args.id int 1 run scoreboard players get @s aj.id
function sweetdream:boss/fireaxe/bar_remove with storage sweetdream:fireaxe args
function sweetdream_boss:reconstruction/animations/death/tween {duration:4,to_frame:0}
playsound minecraft:entity.iron_golem.death hostile @a[distance=..32] ~ ~ ~ 0.65 0.7
