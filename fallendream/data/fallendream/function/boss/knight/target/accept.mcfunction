function fallendream:boss/knight/target/valid
execute unless entity @s[tag=sd.kn.target] run return 0
data modify storage fallendream:knight aggro.u0 set from entity @s UUID[0]
data modify storage fallendream:knight aggro.u1 set from entity @s UUID[1]
data modify storage fallendream:knight aggro.u2 set from entity @s UUID[2]
data modify storage fallendream:knight aggro.u3 set from entity @s UUID[3]
function animated_java:global/gu/get_entity_uuid_string
data modify storage fallendream:knight aggro.uuid set from storage animated_java:gu out
function fallendream:boss/knight/target/store with storage fallendream:knight aggro
