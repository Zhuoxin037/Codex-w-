advancement revoke @s only sweetdream:profession/melee
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0
execute if score @s zx.job matches 2 run function sweetdream:profession/berserker/attack
function sweetdream:lib/victim
execute store result storage zx:work jhit.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work jhit.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work jhit.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work jhit.u3 int 1 run scoreboard players get @s manacore.u3
execute if score @s zx.job matches 1 run function sweetdream:profession/mage/imbue_hit
execute if score @s zx.job matches 4 run function sweetdream:profession/twin/melee
tag @e[tag=zx.victim,distance=0..16] remove zx.victim
