execute unless score #ld_gn zx.meta matches 1.. run return 0
function sweetdream:equipment/armor/late_dusk/expire
scoreboard players set #ld_added zx.meta 0
execute if score @s zx.ld_s matches ..2 run function sweetdream:equipment/armor/late_dusk/gain_one
execute if score #ld_gn zx.meta matches 2.. if score @s zx.ld_s matches ..2 run function sweetdream:equipment/armor/late_dusk/gain_one
execute if score #ld_gn zx.meta matches 3.. if score @s zx.ld_s matches ..2 run function sweetdream:equipment/armor/late_dusk/gain_one
scoreboard players set #ld_gn zx.meta 0
execute unless score #ld_added zx.meta matches 1.. run return 0
particle minecraft:dust{color:[0.55,0.45,0.75],scale:1.3} ~ ~1.2 ~ 0.4 0.4 0.4 0.02 14
playsound minecraft:block.amethyst_block.chime player @s ~ ~ ~ 0.45 1.2
