summon minecraft:zombie ~-4 ~ ~-2 {Tags:["sd.floor_enemy"],IsBaby:0b,PersistenceRequired:1b,CanPickUpLoot:0b,DeathLootTable:"minecraft:empty"}
summon minecraft:husk ~2 ~ ~-4 {Tags:["sd.floor_enemy"],IsBaby:0b,PersistenceRequired:1b,CanPickUpLoot:0b,DeathLootTable:"minecraft:empty"}
summon minecraft:skeleton ~4 ~ ~3 {Tags:["sd.floor_enemy"],PersistenceRequired:1b,CanPickUpLoot:0b,DeathLootTable:"minecraft:empty",equipment:{mainhand:{id:"minecraft:bow",count:1}},drop_chances:{mainhand:0f}}
execute if score #hard sd.floor matches 1 run summon minecraft:husk ~-4 ~ ~3 {Tags:["sd.floor_enemy"],PersistenceRequired:1b,DeathLootTable:"minecraft:empty",Health:32f,attributes:[{id:"minecraft:max_health",base:32d},{id:"minecraft:attack_damage",base:5d}]}
execute if score #hard sd.floor matches 1 run summon minecraft:spider ~ ~ ~5 {Tags:["sd.floor_enemy"],PersistenceRequired:1b,DeathLootTable:"minecraft:empty"}
execute if score #fights sd.floor matches 2.. run summon minecraft:skeleton ~-2 ~ ~5 {Tags:["sd.floor_enemy"],PersistenceRequired:1b,CanPickUpLoot:0b,DeathLootTable:"minecraft:empty",equipment:{mainhand:{id:"minecraft:bow",count:1}},drop_chances:{mainhand:0f}}
