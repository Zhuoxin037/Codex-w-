function fallendream:boss/b_staff/target/valid
execute unless entity @s[tag=sd.bs.target] run return 0
data modify storage fallendream:b_staff target set value {id:0,u0:0,u1:0,u2:0,u3:0,uuid:""}
execute store result storage fallendream:b_staff target.id int 1 run scoreboard players get @e[tag=sd.bs.current_body,distance=0..,limit=1] bs.id
data modify storage fallendream:b_staff target.u0 set from entity @s UUID[0]
data modify storage fallendream:b_staff target.u1 set from entity @s UUID[1]
data modify storage fallendream:b_staff target.u2 set from entity @s UUID[2]
data modify storage fallendream:b_staff target.u3 set from entity @s UUID[3]
function animated_java:global/gu/get_entity_uuid_string
data modify storage fallendream:b_staff target.uuid set from storage animated_java:gu out
function fallendream:boss/b_staff/target/store with storage fallendream:b_staff target
