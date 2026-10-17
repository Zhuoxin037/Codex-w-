function sweetdream:boss/fireaxe/visual/light
tag @s add sd.fb.rig
tag @s add sd.fb.current_rig
summon minecraft:vindicator ~ ~ ~ {Tags:["sd.fb.body","sd.fb.new"],NoAI:1b,Silent:1b,PersistenceRequired:1b,CanPickUpLoot:0b,DeathLootTable:"minecraft:empty",Health:1000.0f,attributes:[{id:"minecraft:max_health",base:1000.0d},{id:"minecraft:scale",base:2.25d},{id:"minecraft:attack_damage",base:0.0d}],active_effects:[{id:"minecraft:invisibility",amplifier:0,duration:-1,show_particles:0b,show_icon:0b}]}
scoreboard players operation @e[tag=sd.fb.new,distance=..0.01,limit=1] sdbf.id = @s aj.id
execute as @e[tag=sd.fb.new,distance=..0.01,limit=1] at @s run function sweetdream:boss/fireaxe/init_body
execute store result storage sweetdream:fireaxe args.id int 1 run scoreboard players get @s aj.id
function sweetdream:boss/fireaxe/bar_create with storage sweetdream:fireaxe args
tag @s remove sd.fb.current_rig
