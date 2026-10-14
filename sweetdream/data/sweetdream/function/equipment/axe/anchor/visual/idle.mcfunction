function sweetdream:equipment/axe/anchor/visual/model_sync
execute if entity @s[tag=zx.av_cast] run return 0
scoreboard players operation #av_pose zx.meta = #now manacore.meta
scoreboard players set #av_cycle zx.meta 80
scoreboard players operation #av_pose zx.meta %= #av_cycle zx.meta
scoreboard players set #av_two zx.meta 2
scoreboard players operation #av_pose zx.meta /= #av_two zx.meta
scoreboard players add #av_pose zx.meta 1
execute if items entity @s weapon.mainhand diamond_axe[custom_data~{zx:["anchor"]}] run function sweetdream:equipment/axe/anchor/visual/idle_main
execute if items entity @s weapon.offhand diamond_axe[custom_data~{zx:["anchor"]}] run function sweetdream:equipment/axe/anchor/visual/idle_off
