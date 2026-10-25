execute if entity @s[nbt={Health:0.0f}] run return 0
data modify storage sweetdream:knight victim.uuid set from entity @s UUID
data modify storage sweetdream:knight victim.id set from storage sweetdream:knight wave.id
function sweetdream:boss/knight/echo/hit_one with storage sweetdream:knight victim
