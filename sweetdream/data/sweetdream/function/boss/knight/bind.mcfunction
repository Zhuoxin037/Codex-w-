tag @s add sd.kn.rig
tag @s add sd.kn.current_rig
execute on passengers run data merge entity @s {brightness:{block:12,sky:12}}
summon minecraft:vindicator ~ ~ ~ {Tags:["sd.kn.body","sd.kn.new"],NoAI:1b,Silent:1b,PersistenceRequired:1b,CanPickUpLoot:0b,DeathLootTable:"minecraft:empty",CustomName:{"text":"\"骑士\""},CustomNameVisible:0b,Health:800f,attributes:[{id:"minecraft:max_health",base:800d},{id:"minecraft:armor",base:9d},{id:"minecraft:armor_toughness",base:20d},{id:"minecraft:scale",base:2.25d},{id:"minecraft:attack_damage",base:0d}],active_effects:[{id:"minecraft:invisibility",amplifier:0,duration:-1,show_particles:0b,show_icon:0b}]}
scoreboard players operation @e[tag=sd.kn.new,distance=..0.01,limit=1] sdk.id = @s aj.id
execute as @e[tag=sd.kn.new,distance=..0.01,limit=1] at @s run function sweetdream:boss/knight/init_body
execute store result storage sweetdream:knight args.id int 1 run scoreboard players get @s aj.id
function sweetdream:boss/knight/bar_create with storage sweetdream:knight args
tp @s ^ ^ ^-0.84375
tag @s remove sd.kn.current_rig
