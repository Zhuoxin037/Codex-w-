execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"],ol:"mottle_vein"}] run return 0
$execute if entity @s[tag=zx.mv2.$(mark)] run return 0
$tag @s add zx.mv2.$(mark)
