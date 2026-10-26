function sweetdream:profession/twin/locate
execute unless score #jbodyfound zx.meta matches 1 run function sweetdream:profession/twin/body_missing
execute unless score @s zx.j_form matches 1 run return 0
execute unless entity @e[tag=zx.j_anchor,distance=..24] run function sweetdream:profession/twin/overrange
execute if score @s zx.j_form matches 1 if items entity @s weapon.mainhand *[custom_data~{zx:["empathy"]}] run effect give @s minecraft:resistance 1 2 true

function sweetdream:profession/twin/guard
