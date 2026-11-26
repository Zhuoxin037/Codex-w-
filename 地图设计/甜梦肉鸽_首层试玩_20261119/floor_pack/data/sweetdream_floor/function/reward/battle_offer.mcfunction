# Cumulative thresholds for the normal and elite battle pools.
data modify storage sweetdream_floor:run battle_draw set value 1b
execute store result score #quality sd.floor run random value 1..10000 sweetdream:rogue
execute if data storage sweetdream_floor:run current{kind:"elite"} run function sweetdream_floor:reward/battle_tier {t1_max:3000,t2_max:6000,t3_max:9200}
execute unless data storage sweetdream_floor:run current{kind:"elite"} run function sweetdream_floor:reward/battle_tier {t1_max:4702,t2_max:7451,t3_max:9609}
function sweetdream_floor:reward/open
