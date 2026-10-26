execute unless entity @s[type=minecraft:player] run return 0
scoreboard players set #jcost zx.meta 0
execute store result score #jcost zx.meta run data get storage manacore:in arg.value 1000
scoreboard players operation @s zx.j_paid = #jcost zx.meta

execute if score @s zx.j_sorrow matches 1 if score @s zx.j_sor_due = #now manacore.meta if score @s zx.j_paid = @s zx.j_sor_need run function sweetdream:profession/mage/sorrow_pay
