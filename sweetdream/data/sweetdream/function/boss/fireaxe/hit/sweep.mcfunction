tag @e[tag=sd.fb.hit,distance=0..] remove sd.fb.hit
execute rotated ~-70 0 positioned ^0 ^1.1 ^ run function sweetdream:boss/fireaxe/ray/0 {steps:8}
execute rotated ~-50 0 positioned ^0 ^1.1 ^ run function sweetdream:boss/fireaxe/ray/0 {steps:8}
execute rotated ~-30 0 positioned ^0 ^1.1 ^ run function sweetdream:boss/fireaxe/ray/0 {steps:8}
execute rotated ~-10 0 positioned ^0 ^1.1 ^ run function sweetdream:boss/fireaxe/ray/0 {steps:8}
execute rotated ~10 0 positioned ^0 ^1.1 ^ run function sweetdream:boss/fireaxe/ray/0 {steps:8}
execute rotated ~30 0 positioned ^0 ^1.1 ^ run function sweetdream:boss/fireaxe/ray/0 {steps:8}
execute rotated ~50 0 positioned ^0 ^1.1 ^ run function sweetdream:boss/fireaxe/ray/0 {steps:8}
execute rotated ~70 0 positioned ^0 ^1.1 ^ run function sweetdream:boss/fireaxe/ray/0 {steps:8}
execute as @e[tag=sd.fb.hit,distance=0..] run damage @s 6 minecraft:mob_attack by @e[tag=sd.fb.current_body,limit=1,distance=0..]
playsound minecraft:entity.player.attack.sweep hostile @a[distance=..24] ~ ~ ~ 1 0.65
tag @e[tag=sd.fb.hit,distance=0..] remove sd.fb.hit
