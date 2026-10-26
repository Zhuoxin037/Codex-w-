# @calc: indep
execute unless entity @s[type=minecraft:player] run return 0
scoreboard players set #jfinal zx.meta 0
execute store result score #jfinal zx.meta run data get storage manacore:out r.damage 1000
execute if score @s zx.j_sor_t = #now manacore.meta run function sweetdream:profession/mage/sorrow_mul
execute store result storage manacore:out r.damage double 0.001 run scoreboard players get #jfinal zx.meta
