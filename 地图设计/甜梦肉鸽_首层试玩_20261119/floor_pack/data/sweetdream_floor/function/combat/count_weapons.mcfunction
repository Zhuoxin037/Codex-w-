execute store result score #weapons sd.floor run clear @s *[minecraft:custom_data~{zx:["sword"]}] 0
execute store result score #count sd.floor run clear @s *[minecraft:custom_data~{zx:["axe"]}] 0
scoreboard players operation #weapons sd.floor += #count sd.floor
execute store result score #count sd.floor run clear @s *[minecraft:custom_data~{zx:["bow"]}] 0
scoreboard players operation #weapons sd.floor += #count sd.floor
execute store result score #count sd.floor run clear @s *[minecraft:custom_data~{zx:["staff"]}] 0
scoreboard players operation #weapons sd.floor += #count sd.floor
