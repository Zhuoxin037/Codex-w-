function sweetdream:lib/uuid
scoreboard players operation #jem_dealt zx.meta = #jem_got zx.meta
scoreboard players operation #jem_dealt zx.meta /= #j2 zx.meta
execute if score @s zx.j_empath matches 1.. run scoreboard players operation #jem_dealt zx.meta = #jem_got zx.meta
execute if score @s zx.j_empath matches 1.. run scoreboard players operation #jem_dealt zx.meta *= #j5 zx.meta
execute if score @s zx.j_empath matches 1.. run scoreboard players operation #jem_dealt zx.meta /= #j2 zx.meta
execute store result storage manacore:out r.damage double .001 run scoreboard players get #jem_dealt zx.meta
execute unless score @s zx.j_empath matches 1.. run function sweetdream:profession/twin/reflect3
execute if score @s zx.j_empath matches 1.. run function sweetdream:profession/twin/reflect5
