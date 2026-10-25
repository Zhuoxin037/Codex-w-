function sweetdream:boss/fireaxe/target/valid
execute unless entity @s[tag=sd.fb.target] run return 0
data modify storage sweetdream:fireaxe aggro.u0 set from entity @s UUID[0]
data modify storage sweetdream:fireaxe aggro.u1 set from entity @s UUID[1]
data modify storage sweetdream:fireaxe aggro.u2 set from entity @s UUID[2]
data modify storage sweetdream:fireaxe aggro.u3 set from entity @s UUID[3]
function animated_java:global/gu/get_entity_uuid_string
data modify storage sweetdream:fireaxe aggro.uuid set from storage animated_java:gu out
function sweetdream:boss/fireaxe/target/store with storage sweetdream:fireaxe aggro
