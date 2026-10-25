# Read-only: +0.5% to the maximum-mana channel per 1% wave movement bonus.
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["ebb_tide"]}] run return 0
execute unless score @s zx.et_s matches 1.. run return 0
scoreboard players set #et_add zx.meta 0
execute store result score #et_add zx.meta run data get storage zx:work add.mm 1000
scoreboard players operation #et_bonus zx.meta = @s zx.et_s
scoreboard players operation #et_bonus zx.meta *= #5 zx.meta
scoreboard players operation #et_add zx.meta += #et_bonus zx.meta
execute store result storage zx:work add.mm double 0.001 run scoreboard players get #et_add zx.meta
