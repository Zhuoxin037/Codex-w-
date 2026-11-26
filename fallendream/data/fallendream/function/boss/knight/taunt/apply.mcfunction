data remove storage fallendream:knight redirect
execute unless entity @e[tag=sd.fb.taunt_source,distance=..12,limit=1] run return 0
data modify storage fallendream:knight redirect.u0 set from entity @e[tag=sd.fb.taunt_source,distance=..12,limit=1] UUID[0]
data modify storage fallendream:knight redirect.u1 set from entity @e[tag=sd.fb.taunt_source,distance=..12,limit=1] UUID[1]
data modify storage fallendream:knight redirect.u2 set from entity @e[tag=sd.fb.taunt_source,distance=..12,limit=1] UUID[2]
data modify storage fallendream:knight redirect.u3 set from entity @e[tag=sd.fb.taunt_source,distance=..12,limit=1] UUID[3]
function fallendream:boss/aggro/redirect with storage fallendream:knight redirect
