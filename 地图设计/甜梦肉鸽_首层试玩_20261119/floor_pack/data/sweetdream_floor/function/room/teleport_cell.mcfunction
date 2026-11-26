# Four blocks east of center is on the flat aisle, clear of room fixtures.
$execute positioned $(x).5 81 $(z).5 positioned ~4 ~ ~ if block ~ ~ ~ minecraft:air if block ~ ~1 ~ minecraft:air unless block ~ ~-1 ~ minecraft:air run return run function sweetdream_floor:room/land {cell:$(cell)}
execute positioned 4.5 81 48.5 run function sweetdream_floor:room/land {cell:10}
