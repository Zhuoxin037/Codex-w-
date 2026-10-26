scoreboard players set @s zx.j_pick 0
scoreboard players remove @s zx.j_draws 1
function sweetdream:lib/uuid
data modify storage zx:work jchoice.uuid set from storage zx:data self.uuid
function sweetdream:profession/mage/choice_clean with storage zx:work jchoice
execute if score @s zx.j_draws matches 1.. run function sweetdream:profession/mage/draw

execute unless score @s zx.j_pick matches 1 run function sweetdream:profession/mage/resistance_end
