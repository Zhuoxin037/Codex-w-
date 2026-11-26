tag @e[tag=sd.bs.target,distance=0..] remove sd.bs.target
tag @s add sd.bs.current_body
$execute as @e[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=..24,limit=1] at @s run function fallendream:boss/b_staff/target/accept
execute if entity @e[tag=sd.bs.target,distance=0..] run data modify storage fallendream:aggro out.success set value true
execute store result score @s bs.lastHP run data get entity @s Health 1000
tag @e[tag=sd.bs.target,distance=0..] remove sd.bs.target
tag @s remove sd.bs.current_body
