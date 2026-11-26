execute store result storage fallendream:husk aggro.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage fallendream:husk aggro.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage fallendream:husk aggro.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage fallendream:husk aggro.u3 int 1 run scoreboard players get @s manacore.u3
function fallendream:boss/husk/uuid/player
data modify storage fallendream:husk aggro.uuid set from storage fallendream:husk player_uuid
function fallendream:boss/husk/target/store with storage fallendream:husk aggro
