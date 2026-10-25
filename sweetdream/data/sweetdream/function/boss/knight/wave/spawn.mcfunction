scoreboard players set @s sdk.hit0 1
scoreboard players add @s sdk.wavecount 1
scoreboard players set @s sdk.echo 0
execute if score @s sdk.wavecount matches 3.. run scoreboard players set @s sdk.echo 1
execute if score @s sdk.phase matches 2 run scoreboard players set @s sdk.echo 1
execute if score @s sdk.wavecount matches 3.. run scoreboard players set @s sdk.wavecount 0
scoreboard players add #wave sdk.serial 1
execute positioned ^0.96725 ^1.03676 ^3.28037 run summon minecraft:item_display ~ ~ ~ {Tags:["sd.kn.wave","sd.kn.fx","sd.kn.newwave"],item:{id:"minecraft:white_dye",components:{"minecraft:item_model":"sweetdream:boss/knight_wave"}},item_display:"none",brightness:{block:12,sky:12},view_range:1f,teleport_duration:1,interpolation_duration:1,shadow_radius:0f,transformation:{translation:[0f,0f,0f],scale:[2.4f,3.0f,2.4f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}
scoreboard players operation @e[tag=sd.kn.newwave,distance=..8,limit=1] sdk.owner = @s sdk.id
scoreboard players operation @e[tag=sd.kn.newwave,distance=..8,limit=1] sdk.waveid = #wave sdk.serial
scoreboard players operation @e[tag=sd.kn.newwave,distance=..8,limit=1] sdk.echo = @s sdk.echo
scoreboard players set @e[tag=sd.kn.newwave,distance=..8,limit=1] sdk.age 0
scoreboard players set @e[tag=sd.kn.newwave,distance=..8,limit=1] sdk.traces 0
data modify entity @e[tag=sd.kn.newwave,distance=..8,limit=1] Rotation set from entity @s Rotation
data modify entity @e[tag=sd.kn.newwave,distance=..8,limit=1] Rotation[1] set value 0f
tag @e[tag=sd.kn.newwave,distance=..8,limit=1] remove sd.kn.newwave
playsound minecraft:entity.evoker.cast_spell hostile @a[distance=..32] ~ ~ ~ 0.5 1.3
