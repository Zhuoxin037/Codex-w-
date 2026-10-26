$data modify entity @e[type=minecraft:allay,tag=zx.j_new,limit=1] data set value {owner:"$(uuid)",u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
$execute if data storage zx:jobs p."$(uuid)".twin.max run data modify entity @e[type=minecraft:allay,tag=zx.j_new,limit=1] attributes[{id:"minecraft:max_health"}].base set from storage zx:jobs p."$(uuid)".twin.max
$data modify entity @e[type=minecraft:allay,tag=zx.j_new,limit=1] Health set from storage zx:jobs p."$(uuid)".twin.hp
