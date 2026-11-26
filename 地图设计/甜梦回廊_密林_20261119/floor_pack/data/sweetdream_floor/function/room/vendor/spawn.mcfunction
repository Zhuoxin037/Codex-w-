$summon minecraft:villager ~$(x) ~ ~$(z) {Tags:["sd.floor_vendor"],NoAI:1b,Invulnerable:1b,Silent:1b,PersistenceRequired:1b,Rotation:[-90.0f,0.0f],VillagerData:{type:"minecraft:taiga",profession:"minecraft:$(profession)",level:2},Offers:{Recipes:[]},CustomName:{text:"$(name)",color:"gold"}}
$summon minecraft:interaction ~$(x) ~ ~$(z) {Tags:["sd.floor_vendor_hitbox"],width:0.95f,height:2.15f,response:1b}
$execute positioned ~$(x) ~ ~$(z) run team join sd.floor_vendor @e[type=minecraft:villager,tag=sd.floor_vendor,distance=..1,limit=1]
