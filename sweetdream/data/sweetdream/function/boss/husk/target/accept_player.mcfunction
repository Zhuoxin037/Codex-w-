execute store result storage sweetdream:husk aggro.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage sweetdream:husk aggro.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage sweetdream:husk aggro.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage sweetdream:husk aggro.u3 int 1 run scoreboard players get @s manacore.u3
function sweetdream:lib/uuid
data modify storage sweetdream:husk aggro.uuid set from storage zx:data self.uuid
function sweetdream:boss/husk/target/store with storage sweetdream:husk aggro
