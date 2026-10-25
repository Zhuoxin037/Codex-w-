execute if entity @s[tag=sd.kn.hit] run return 0
execute unless data entity @s Health run return 0
execute if entity @s[nbt={Health:0.0f}] run return 0
tag @s add sd.kn.hit
function sweetdream:boss/knight/hit/sight
