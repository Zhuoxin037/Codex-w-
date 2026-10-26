execute if entity @s[tag=zx.j_eroded] run return run function sweetdream:profession/twin/boss_forget
tag @e[tag=sd.hk.target,distance=0..] remove sd.hk.target
execute store result storage sweetdream:husk aggro.id int 1 run scoreboard players get @s sdh.id
scoreboard players operation #aggro sdh.id = @s sdh.id
execute store result score @s sdh.hp1000 run data get entity @s Health 1000
execute if score @s sdh.hp1000 < @s sdh.target_hp on attacker at @s run function sweetdream:boss/husk/target/accept
scoreboard players operation @s sdh.target_hp = @s sdh.hp1000
tag @e[tag=sd.hk.target,distance=0..] remove sd.hk.target
function sweetdream:boss/husk/target/load with storage sweetdream:husk aggro
execute unless entity @e[tag=sd.hk.target,distance=0..] as @a[gamemode=!creative,gamemode=!spectator,distance=..30,sort=nearest,limit=1] at @s run function sweetdream:boss/husk/target/accept
