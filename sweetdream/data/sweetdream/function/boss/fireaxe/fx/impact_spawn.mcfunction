execute if block ~ ~-0.1 ~ #sweetdream:boss_passable run return 0
data modify storage sweetdream:fireaxe fx_block set value {Name:"minecraft:stone"}
execute if block ~ ~-0.1 ~ #minecraft:dirt run data modify storage sweetdream:fireaxe fx_block set value {Name:"minecraft:dirt"}
execute if block ~ ~-0.1 ~ minecraft:sand run data modify storage sweetdream:fireaxe fx_block set value {Name:"minecraft:sand"}
execute if block ~ ~-0.1 ~ minecraft:deepslate run data modify storage sweetdream:fireaxe fx_block set value {Name:"minecraft:deepslate"}
execute if block ~ ~-0.1 ~ #minecraft:planks run data modify storage sweetdream:fireaxe fx_block set value {Name:"minecraft:oak_planks"}
summon minecraft:item_display ~ ~0.025 ~ {Tags:["sd.fb.fx","sd.fb.fx_new","sd.fb.fx.crack"],item_display:"none",view_range:8f,width:12f,height:5f,shadow_radius:0f,interpolation_duration:0,transformation:{translation:[0f,0f,0f],left_rotation:[0f,0f,0f,1f],scale:[3.2f,3.2f,3.2f],right_rotation:[0f,0f,0f,1f]},item:{id:"minecraft:paper",count:1,components:{"minecraft:item_model":"sweetdream_boss:blueprint/reconstruction/fx/crack_0"}}}
execute as @e[tag=sd.fb.fx_new,distance=..3,limit=1] run tp @s ~ ~0.025 ~ ~ 0
scoreboard players set @e[tag=sd.fb.fx_new,distance=..3,limit=1] sdbf.fxage 0
execute if score @s sdbf.phase matches 3 run data modify entity @e[tag=sd.fb.fx_new,distance=..3,limit=1] transformation.scale set value [3.87f,3.87f,3.87f]
tag @e[tag=sd.fb.fx_new,distance=..3] remove sd.fb.fx_new
execute rotated ~12 0 positioned ^ ^0.08 ^1.1 run function sweetdream:boss/fireaxe/fx/chunk_spawn
execute rotated ~65 0 positioned ^ ^0.08 ^1.65 run function sweetdream:boss/fireaxe/fx/chunk_spawn
execute rotated ~117 0 positioned ^ ^0.08 ^2.2 run function sweetdream:boss/fireaxe/fx/chunk_spawn
execute rotated ~172 0 positioned ^ ^0.08 ^1.3 run function sweetdream:boss/fireaxe/fx/chunk_spawn
execute rotated ~224 0 positioned ^ ^0.08 ^1.9 run function sweetdream:boss/fireaxe/fx/chunk_spawn
execute rotated ~280 0 positioned ^ ^0.08 ^2.3 run function sweetdream:boss/fireaxe/fx/chunk_spawn
particle minecraft:block{block_state:"minecraft:stone"} ~ ~0.12 ~ 1.7 0.12 1.7 0.08 32 normal
