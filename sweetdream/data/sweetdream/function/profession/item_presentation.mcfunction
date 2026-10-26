# The caller owns zx.st_tmp; never write player NBT or change gameplay enchantments.
execute unless items entity @e[tag=zx.st_tmp,limit=1] weapon.mainhand *[custom_data~{profession:1}] unless items entity @e[tag=zx.st_tmp,limit=1] weapon.mainhand *[custom_data~{profession:4}] run return 0
scoreboard players set #jpres zx.meta 0
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:enchantments"."sweetdream:job_1" run scoreboard players set #jpres zx.meta 1
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:enchantments"."sweetdream:job_4" run scoreboard players set #jpres zx.meta 1
execute unless score #jpres zx.meta matches 1 run return 0
data modify entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:enchantment_glint_override" set value 0b
execute unless data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:tooltip_display".hidden_components run data modify entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:tooltip_display".hidden_components set value []
execute unless data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:tooltip_display"{hidden_components:["minecraft:enchantments"]} run data modify entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:tooltip_display".hidden_components append value "minecraft:enchantments"
