function sweetdream:boss/knight/target/valid
execute unless entity @s[tag=sd.kn.target] run return 0
data modify storage sweetdream:knight aggro.u0 set from entity @s UUID[0]
data modify storage sweetdream:knight aggro.u1 set from entity @s UUID[1]
data modify storage sweetdream:knight aggro.u2 set from entity @s UUID[2]
data modify storage sweetdream:knight aggro.u3 set from entity @s UUID[3]
function animated_java:global/gu/get_entity_uuid_string
data modify storage sweetdream:knight aggro.uuid set from storage animated_java:gu out
function sweetdream:boss/knight/target/store with storage sweetdream:knight aggro
