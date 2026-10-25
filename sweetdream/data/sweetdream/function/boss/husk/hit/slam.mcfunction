scoreboard players set @s sdh.hit0 1
scoreboard players operation #amount sdh.tmp = @s sdh.energy
scoreboard players set #4 sdh.tmp 4
scoreboard players operation #amount sdh.tmp /= #4 sdh.tmp
scoreboard players add #amount sdh.tmp 14000
execute store result storage sweetdream:husk damage.amount double 0.001 run scoreboard players get #amount sdh.tmp
data modify storage sweetdream:husk damage.cap set value 2.5
tag @e[tag=sd.hk.hit,distance=..6] remove sd.hk.hit
execute positioned ^-0.6800 ^0.5 ^0.9200 positioned ~-0.35 ~-0.45 ~-0.35 as @a[gamemode=!creative,gamemode=!spectator,dx=0.7,dy=1.2,dz=0.7] unless entity @s[tag=sd.hk.hit] run function sweetdream:boss/husk/hit/candidate
execute positioned ^-0.6800 ^0.5 ^0.9200 positioned ~-0.35 ~-0.45 ~-0.35 as @e[tag=sd.hk.target,type=!minecraft:player,dx=0.7,dy=1.2,dz=0.7] unless entity @s[tag=sd.hk.hit] run function sweetdream:boss/husk/hit/candidate
execute positioned ^-0.4000 ^0.5 ^1.3000 positioned ~-0.35 ~-0.45 ~-0.35 as @a[gamemode=!creative,gamemode=!spectator,dx=0.7,dy=1.2,dz=0.7] unless entity @s[tag=sd.hk.hit] run function sweetdream:boss/husk/hit/candidate
execute positioned ^-0.4000 ^0.5 ^1.3000 positioned ~-0.35 ~-0.45 ~-0.35 as @e[tag=sd.hk.target,type=!minecraft:player,dx=0.7,dy=1.2,dz=0.7] unless entity @s[tag=sd.hk.hit] run function sweetdream:boss/husk/hit/candidate
execute positioned ^0.0000 ^0.5 ^1.6500 positioned ~-0.35 ~-0.45 ~-0.35 as @a[gamemode=!creative,gamemode=!spectator,dx=0.7,dy=1.2,dz=0.7] unless entity @s[tag=sd.hk.hit] run function sweetdream:boss/husk/hit/candidate
execute positioned ^0.0000 ^0.5 ^1.6500 positioned ~-0.35 ~-0.45 ~-0.35 as @e[tag=sd.hk.target,type=!minecraft:player,dx=0.7,dy=1.2,dz=0.7] unless entity @s[tag=sd.hk.hit] run function sweetdream:boss/husk/hit/candidate
execute positioned ^0.4000 ^0.5 ^1.3000 positioned ~-0.35 ~-0.45 ~-0.35 as @a[gamemode=!creative,gamemode=!spectator,dx=0.7,dy=1.2,dz=0.7] unless entity @s[tag=sd.hk.hit] run function sweetdream:boss/husk/hit/candidate
execute positioned ^0.4000 ^0.5 ^1.3000 positioned ~-0.35 ~-0.45 ~-0.35 as @e[tag=sd.hk.target,type=!minecraft:player,dx=0.7,dy=1.2,dz=0.7] unless entity @s[tag=sd.hk.hit] run function sweetdream:boss/husk/hit/candidate
execute positioned ^0.6800 ^0.5 ^0.9200 positioned ~-0.35 ~-0.45 ~-0.35 as @a[gamemode=!creative,gamemode=!spectator,dx=0.7,dy=1.2,dz=0.7] unless entity @s[tag=sd.hk.hit] run function sweetdream:boss/husk/hit/candidate
execute positioned ^0.6800 ^0.5 ^0.9200 positioned ~-0.35 ~-0.45 ~-0.35 as @e[tag=sd.hk.target,type=!minecraft:player,dx=0.7,dy=1.2,dz=0.7] unless entity @s[tag=sd.hk.hit] run function sweetdream:boss/husk/hit/candidate
tag @e[tag=sd.hk.hit,distance=..6] remove sd.hk.hit
