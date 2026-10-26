execute if entity @s[tag=zx.j_eroded] run return run function sweetdream:profession/twin/boss_forget
tag @e[tag=sd.kn.target,distance=0..] remove sd.kn.target
execute store result storage sweetdream:knight aggro.id int 1 run scoreboard players get @s sdk.id
scoreboard players operation #aggro sdk.id = @s sdk.id
execute store result score @s sdk.hp1000 run data get entity @s Health 1000
execute if score @s sdk.hp1000 < @s sdk.last_hp on attacker at @s run function sweetdream:boss/knight/target/accept
scoreboard players operation @s sdk.last_hp = @s sdk.hp1000
tag @e[tag=sd.kn.target,distance=0..] remove sd.kn.target
function sweetdream:boss/knight/target/load with storage sweetdream:knight aggro
execute unless entity @e[tag=sd.kn.target,distance=0..] as @a[gamemode=!creative,gamemode=!spectator,distance=..30,sort=nearest,limit=1,nbt=!{Health:0.0f}] at @s run function sweetdream:boss/knight/target/accept
