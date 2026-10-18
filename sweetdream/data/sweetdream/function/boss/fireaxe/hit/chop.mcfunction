tag @e[tag=sd.fb.hit,distance=0..] remove sd.fb.hit
execute rotated ~0 0 positioned ^-0.5 ^1.1 ^ run function sweetdream:boss/fireaxe/ray/0 {steps:10}
execute rotated ~0 0 positioned ^0 ^1.1 ^ run function sweetdream:boss/fireaxe/ray/0 {steps:10}
execute rotated ~0 0 positioned ^0.5 ^1.1 ^ run function sweetdream:boss/fireaxe/ray/0 {steps:10}
function sweetdream:boss/fireaxe/damage/begin {base:9}
playsound minecraft:entity.player.attack.sweep hostile @a[distance=..24] ~ ~ ~ 1 0.65
playsound minecraft:entity.zombie.attack_iron_door hostile @a[distance=..24] ~ ~ ~ 0.8 0.7
particle minecraft:poof ~ ~0.1 ~ 0.7 0.05 0.7 0.03 15 normal
tag @e[tag=sd.fb.hit,distance=0..] remove sd.fb.hit
