# Stronger or equally strong external slowness already satisfies the field; leave it intact.
scoreboard players set #tj_amp zx.meta -1
execute store result score #tj_amp zx.meta run data get entity @s active_effects[{id:"minecraft:slowness"}].amplifier
execute if score #tj_amp zx.meta matches 2.. run return 0
execute if score #tj_amp zx.meta matches 1 unless data entity @s active_effects[{id:"minecraft:slowness",ambient:1b,show_icon:0b}] run return 0
execute if data entity @s active_effects[{id:"minecraft:slowness",ambient:1b,show_icon:0b}] store result score #tj_duration zx.meta run data get entity @s active_effects[{id:"minecraft:slowness"}].duration
execute if score #tj_amp zx.meta matches 1 if score #tj_duration zx.meta matches 21.. run return 0
effect give @s minecraft:slowness 2 1 true
data modify entity @s active_effects[{id:"minecraft:slowness"}].ambient set value 1b
data modify entity @s active_effects[{id:"minecraft:slowness"}].show_icon set value 0b
