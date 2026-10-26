scoreboard players set @s sdh.hit0 1
# energy is cumulative actual HP lost, in 1/1000 HP. Half-milli storage preserves odd halves.
scoreboard players operation #amount sdh.tmp = @s sdh.energy
execute if score @s sdh.leapmode matches 0 run scoreboard players add #amount sdh.tmp 12000
execute if score @s sdh.leapmode matches 1 run scoreboard players add #amount sdh.tmp 28000
execute store result storage sweetdream:husk damage.amount double 0.0005 run scoreboard players get #amount sdh.tmp
execute if score @s sdh.leapmode matches 0 run data modify storage sweetdream:husk damage.cap set value 4.0
execute if score @s sdh.leapmode matches 1 run data modify storage sweetdream:husk damage.cap set value 3.0
tag @e[tag=sd.hk.hit,distance=..6] remove sd.hk.hit
execute as @a[gamemode=!creative,gamemode=!spectator,distance=..4] run function sweetdream:boss/husk/hit/candidate
execute as @e[tag=sd.hk.target,type=!minecraft:player,distance=..4] run function sweetdream:boss/husk/hit/candidate
tag @e[tag=sd.hk.hit,distance=..6] remove sd.hk.hit
playsound minecraft:entity.generic.explode hostile @a[distance=..32] ~ ~ ~ 1.4 0.8
