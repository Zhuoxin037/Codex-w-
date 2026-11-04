tag @e[tag=zx.cs_support,distance=0..] remove zx.cs_support
tag @e[tag=zx.cs_singing,distance=0..] remove zx.cs_singing
tag @e[tag=zx.cs_final_hit,distance=0..] remove zx.cs_final_hit
$execute as @a[distance=0..] at @s run function sweetdream:equipment/staff/chorus/support_one {owner:"$(owner)"}
$tag @e[tag=zx.cs_voice,tag=zx.cs_support,distance=0..,nbt={data:{c0:$(c0),c1:$(c1),c2:$(c2),c3:$(c3)}}] add zx.cs_singing
$execute as @e[tag=zx.cs_voice,tag=!zx.cs_support,scores={zx.cs_echo=1..},distance=0..,nbt={data:{c0:$(c0),c1:$(c1),c2:$(c2),c3:$(c3)}}] run function sweetdream:equipment/staff/chorus/auto_voice
scoreboard players set #chorus_active zx.meta 0
$execute store result score #chorus_active zx.meta if entity @e[tag=zx.cs_singing,distance=0..,nbt={data:{c0:$(c0),c1:$(c1),c2:$(c2),c3:$(c3)}}]
scoreboard players set #chorus_final zx.meta 0
execute if score @s zx.cs_left matches 0 if score #chorus_active zx.meta matches 3 run scoreboard players set #chorus_final zx.meta 1
scoreboard players operation #chorus_mul zx.meta = #chorus_active zx.meta
scoreboard players remove #chorus_mul zx.meta 1
scoreboard players set #chorus_quarter zx.meta 250
scoreboard players operation #chorus_mul zx.meta *= #chorus_quarter zx.meta
scoreboard players add #chorus_mul zx.meta 1000
$execute as @e[tag=zx.cs_singing,distance=0..,nbt={data:{c0:$(c0),c1:$(c1),c2:$(c2),c3:$(c3)}}] at @s run function sweetdream:equipment/staff/chorus/voice_damage
data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
execute if score #chorus_final zx.meta matches 1 as @a[tag=zx.ub,scores={zx.job=3},distance=0..,limit=1] at @s run function sweetdream:equipment/staff/chorus/finale
tag @e[tag=zx.cs_support,distance=0..] remove zx.cs_support
tag @e[tag=zx.cs_singing,distance=0..] remove zx.cs_singing
tag @e[tag=zx.cs_final_hit,distance=0..] remove zx.cs_final_hit
