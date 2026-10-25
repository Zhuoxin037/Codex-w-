scoreboard players set @s sdh.hit0 1
scoreboard players operation #amount sdh.tmp = @s sdh.energy
scoreboard players operation #amount sdh.tmp /= #5 sdh.tmp
scoreboard players add #amount sdh.tmp 6000
execute store result storage sweetdream:husk damage.amount double 0.001 run scoreboard players get #amount sdh.tmp
data modify storage sweetdream:husk damage.cap set value 3.5
tag @e[tag=sd.hk.hit,distance=..6] remove sd.hk.hit
execute as @a[gamemode=!creative,gamemode=!spectator,distance=..3.5] run function sweetdream:boss/husk/hit/candidate
execute as @e[tag=sd.hk.target,type=!minecraft:player,distance=..3.5] run function sweetdream:boss/husk/hit/candidate
tag @e[tag=sd.hk.hit,distance=..6] remove sd.hk.hit
