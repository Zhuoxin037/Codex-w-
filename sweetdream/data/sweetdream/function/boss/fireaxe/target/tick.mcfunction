tag @e[tag=sd.fb.target,distance=0..] remove sd.fb.target
execute store result storage sweetdream:fireaxe aggro.id int 1 run scoreboard players get @s sdbf.id
scoreboard players operation #aggro sdbf.id = @s sdbf.id
execute store result score @s sdbf.hp1000 run data get entity @s Health 1000
execute if score @s sdbf.hp1000 < @s sdbf.last_hp on attacker at @s run function sweetdream:boss/fireaxe/target/accept
scoreboard players operation @s sdbf.last_hp = @s sdbf.hp1000
tag @e[tag=sd.fb.target,distance=0..] remove sd.fb.target
function sweetdream:boss/fireaxe/target/load with storage sweetdream:fireaxe aggro
execute unless entity @e[tag=sd.fb.target,distance=0..] as @a[gamemode=!creative,gamemode=!spectator,distance=..24,sort=nearest,limit=1,nbt=!{Health:0.0f}] at @s run function sweetdream:boss/fireaxe/target/accept
