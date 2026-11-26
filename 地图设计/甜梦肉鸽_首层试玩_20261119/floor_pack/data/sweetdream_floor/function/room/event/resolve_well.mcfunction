execute if score #input sd.floor matches 20 run effect give @s minecraft:instant_health 1 5 true
execute if score #input sd.floor matches 21 run function sweetdream_floor:run/mana {value:100000.0}
playsound minecraft:block.amethyst_block.chime player @s ~ ~ ~ 0.8 1.0
