tag @s add sd.hk.rig
tag @s add sd.hk.current_rig
execute on passengers run data merge entity @s {brightness:{block:12,sky:12}}
summon minecraft:vindicator ~ ~ ~ {Tags:["sd.hk.body","sd.hk.new"],NoAI:1b,Silent:1b,PersistenceRequired:1b,CanPickUpLoot:0b,DeathLootTable:"minecraft:empty",CustomName:{text:"空壳"},CustomNameVisible:0b,Health:1000f,attributes:[{id:"minecraft:max_health",base:1000d},{id:"minecraft:armor",base:0d},{id:"minecraft:scale",base:1.5d},{id:"minecraft:knockback_resistance",base:0.8d},{id:"minecraft:attack_damage",base:0d}],active_effects:[{id:"minecraft:invisibility",amplifier:0,duration:-1,show_particles:0b,show_icon:0b}]}
scoreboard players operation @e[tag=sd.hk.new,distance=..0.01,limit=1] sdh.id = @s aj.id
execute as @e[tag=sd.hk.new,distance=..0.01,limit=1] at @s run function sweetdream:boss/husk/init_body
execute store result storage sweetdream:husk args.id int 1 run scoreboard players get @s aj.id
function sweetdream:boss/husk/bar/create with storage sweetdream:husk args
tag @s remove sd.hk.current_rig
