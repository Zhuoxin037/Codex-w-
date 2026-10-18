tag @e[tag=sd.fb.hit,distance=0..] remove sd.fb.hit
execute positioned ~-5.6 ~-1.5 ~-5.6 as @a[gamemode=!creative,gamemode=!spectator,dx=11.2,dy=4,dz=11.2] positioned ~5.6 ~1.5 ~5.6 facing entity @s feet rotated ~ 0 positioned ~ ~1.1 ~ run function sweetdream:boss/fireaxe/impact/ray_0
execute positioned ~-5.6 ~-1.5 ~-5.6 as @e[tag=sd.fb.target,type=!minecraft:player,dx=11.2,dy=4,dz=11.2] positioned ~5.6 ~1.5 ~5.6 facing entity @s feet rotated ~ 0 positioned ~ ~1.1 ~ run function sweetdream:boss/fireaxe/impact/ray_0
function sweetdream:boss/fireaxe/damage/begin {base:12}
playsound minecraft:entity.player.attack.sweep hostile @a[distance=..24] ~ ~ ~ 1 0.65
playsound minecraft:entity.zombie.attack_iron_door hostile @a[distance=..24] ~ ~ ~ 0.8 0.7
particle minecraft:poof ~ ~0.1 ~ 0.7 0.05 0.7 0.03 15 normal
function sweetdream:boss/fireaxe/impact/ring
function sweetdream:boss/fireaxe/fx/impact_spawn
tag @e[tag=sd.fb.hit,distance=0..] remove sd.fb.hit
