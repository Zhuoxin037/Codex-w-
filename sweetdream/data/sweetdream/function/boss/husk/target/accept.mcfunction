function sweetdream:boss/husk/target/valid
execute unless entity @s[tag=sd.hk.target] run return 0
execute if entity @s[type=minecraft:player] run return run function sweetdream:boss/husk/target/accept_player
data modify storage sweetdream:husk aggro.u0 set from entity @s UUID[0]
data modify storage sweetdream:husk aggro.u1 set from entity @s UUID[1]
data modify storage sweetdream:husk aggro.u2 set from entity @s UUID[2]
data modify storage sweetdream:husk aggro.u3 set from entity @s UUID[3]
function animated_java:global/gu/get_entity_uuid_string
data modify storage sweetdream:husk aggro.uuid set from storage animated_java:gu out
function sweetdream:boss/husk/target/store with storage sweetdream:husk aggro
