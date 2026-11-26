function fallendream:boss/fireaxe/target/valid
execute unless entity @s[tag=sd.fb.target] run return 0
data modify storage fallendream:fireaxe aggro.u0 set from entity @s UUID[0]
data modify storage fallendream:fireaxe aggro.u1 set from entity @s UUID[1]
data modify storage fallendream:fireaxe aggro.u2 set from entity @s UUID[2]
data modify storage fallendream:fireaxe aggro.u3 set from entity @s UUID[3]
function animated_java:global/gu/get_entity_uuid_string
data modify storage fallendream:fireaxe aggro.uuid set from storage animated_java:gu out
function fallendream:boss/fireaxe/target/store with storage fallendream:fireaxe aggro
