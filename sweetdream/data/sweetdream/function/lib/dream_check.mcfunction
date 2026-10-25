$data modify storage zx:work dc set value {mark:"$(mark)"}
execute unless data storage zx:work dc{mark:"dream"} run return 0
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["late_dusk"]}] run return 0
scoreboard players set #ld_gn zx.meta 0
$execute as $(target) unless entity @s[type=minecraft:player] if data entity @s Health unless data entity @s {Health:0.0f} run scoreboard players add #ld_gn zx.meta 1
execute if score #ld_gn zx.meta matches 1.. run function sweetdream:equipment/armor/late_dusk/gain_n
