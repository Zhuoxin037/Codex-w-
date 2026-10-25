execute store result storage sweetdream:knight aggro.id int 1 run scoreboard players get @s sdk.id
scoreboard players operation #aggro sdk.id = @s sdk.id
tag @e[tag=sd.kn.target,distance=0..] remove sd.kn.target
$execute as @e[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=..30,limit=1] at @s run function sweetdream:boss/knight/target/accept
execute unless entity @e[tag=sd.kn.target,distance=0..] run return 0
data modify storage sweetdream:aggro out.success set value true
execute store result score @s sdk.last_hp run data get entity @s Health 1000
tag @e[tag=sd.kn.target,distance=0..] remove sd.kn.target
