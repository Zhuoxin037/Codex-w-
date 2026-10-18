execute store result storage sweetdream:fireaxe aggro.id int 1 run scoreboard players get @s sdbf.id
scoreboard players operation #aggro sdbf.id = @s sdbf.id
tag @e[tag=sd.fb.target,distance=0..] remove sd.fb.target
$execute as @e[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=..30,limit=1] at @s run function sweetdream:boss/fireaxe/target/accept
execute unless entity @e[tag=sd.fb.target,distance=0..] run return 0
data modify storage sweetdream:aggro out.success set value true
execute store result score @s sdbf.last_hp run data get entity @s Health 1000
tag @e[tag=sd.fb.target,distance=0..] remove sd.fb.target
