execute if entity @s[nbt={Health:0.0f}] run return 0
data modify storage fallendream:knight victim.uuid set from entity @s UUID
data modify storage fallendream:knight victim.id set from storage fallendream:knight wave.id
function fallendream:boss/knight/wave/hit_one with storage fallendream:knight victim
