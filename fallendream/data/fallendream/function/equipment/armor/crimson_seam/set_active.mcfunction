scoreboard players set #cr_set zx.meta 0
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["needle_sleep"]}] if items entity @s armor.chest *[minecraft:custom_data~{zx:["crimson_seam"]}] run scoreboard players set #cr_set zx.meta 1
execute if score @s zx.ns_set_end > #now manacore.meta if items entity @s armor.head *[minecraft:custom_data~{zx:["needle_sleep"]}] run scoreboard players set #cr_set zx.meta 1
execute if score @s zx.ns_set_end > #now manacore.meta if items entity @s armor.chest *[minecraft:custom_data~{zx:["crimson_seam"]}] run scoreboard players set #cr_set zx.meta 1
