execute unless entity @s[tag=zx.sf_units_v2] run scoreboard players operation @s zx.sf_acc *= #1000 zx.meta
tag @s add zx.sf_units_v2
scoreboard players add @s zx.sf_acc 0
execute if score #sf_gain zx.meta matches 1.. run scoreboard players operation @s zx.sf_acc += #sf_gain zx.meta
execute if score @s zx.sf_acc matches ..9999 run return 0
execute if score @s zx.sf_cd > #now manacore.meta run return 0
scoreboard players remove @s zx.sf_acc 10000
scoreboard players operation @s zx.sf_cd = #now manacore.meta
scoreboard players add @s zx.sf_cd 80
execute at @s run function sweetdream:equipment/tool/sip_frost/go
