$data modify entity @e[type=minecraft:villager,tag=zx.j_new,limit=1] data set value {owner:"$(uuid)",u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
$data modify entity @e[type=minecraft:villager,tag=zx.j_new,limit=1] attributes[{id:"minecraft:max_health"}].base set from storage zx:jobs p."$(uuid)".body.max
$data modify entity @e[type=minecraft:villager,tag=zx.j_new,limit=1] Health set from storage zx:jobs p."$(uuid)".body.hp
