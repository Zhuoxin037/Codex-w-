execute if block ~ ~-0.2 ~ #sweetdream:boss_passable run return 0
summon minecraft:block_display ~ ~ ~ {Tags:["sd.fb.fx","sd.fb.fx_new","sd.fb.fx.chunk"],view_range:8f,teleport_duration:1,shadow_radius:0f,transformation:{translation:[-0.13f,0f,-0.13f],scale:[0.26f,0.19f,0.23f],left_rotation:[0.2f,0.3f,0.1f,0.92736185f],right_rotation:[0f,0f,0f,1f]},block_state:{Name:"minecraft:stone"}}
execute as @e[tag=sd.fb.fx_new,distance=..0.05,limit=1] run tp @s ~ ~ ~ ~ 0
data modify entity @e[tag=sd.fb.fx_new,distance=..0.05,limit=1] block_state set from storage sweetdream:fireaxe fx_block
scoreboard players set @e[tag=sd.fb.fx_new,distance=..0.05,limit=1] sdbf.fxage 0
scoreboard players set @e[tag=sd.fb.fx_new,distance=..0.05,limit=1] sdbf.fxland 0
tag @e[tag=sd.fb.fx_new,distance=..0.05] remove sd.fb.fx_new
