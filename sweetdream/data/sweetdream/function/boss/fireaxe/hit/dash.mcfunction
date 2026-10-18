tag @e[tag=sd.fb.hit,distance=0..] remove sd.fb.hit
execute rotated ~-105 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~-95 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~-85 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~-75 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~-65 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~-55 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~-45 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~-35 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~-25 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~-15 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~-5 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~5 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~15 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~25 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~35 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~45 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~55 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~65 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~75 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~85 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~95 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
execute rotated ~105 0 positioned ^ ^1.1 ^ run function sweetdream:boss/fireaxe/sweep_ray/0
function sweetdream:boss/fireaxe/damage/begin {base:8}
playsound minecraft:entity.player.attack.sweep hostile @a[distance=..24] ~ ~ ~ 1 0.65
function sweetdream:boss/fireaxe/fx/sweep_spawn
tag @e[tag=sd.fb.hit,distance=0..] remove sd.fb.hit
