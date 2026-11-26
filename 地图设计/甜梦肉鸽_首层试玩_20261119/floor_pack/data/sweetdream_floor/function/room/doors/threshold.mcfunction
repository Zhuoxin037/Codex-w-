$execute if score #door_closed sd.floor matches 0 run return run fill ~-$(x) ~ ~-$(z) ~$(x) ~4 ~$(z) minecraft:air replace minecraft:magenta_stained_glass
$execute positioned ~-$(x) ~ ~-$(z) if entity @s[dx=$(width),dy=4,dz=$(depth)] run function sweetdream_floor:room/return_to_explored
$fill ~-$(x) ~ ~-$(z) ~$(x) ~4 ~$(z) minecraft:magenta_stained_glass replace minecraft:air
