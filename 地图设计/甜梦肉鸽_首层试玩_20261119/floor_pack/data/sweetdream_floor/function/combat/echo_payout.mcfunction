scoreboard players set #per_echo sd.floor 8
execute if score #boon sd.floor matches 1 run scoreboard players add #per_echo sd.floor 6
scoreboard players operation #echo sd.floor *= #per_echo sd.floor
execute store result storage sweetdream_floor:run echo.value int 1 run scoreboard players get #echo sd.floor
function sweetdream_floor:run/mana with storage sweetdream_floor:run echo
title @s actionbar [{"text":"回响 · 魔力 +","color":"aqua"},{"score":{"name":"#echo","objective":"sd.floor"}}]
scoreboard players set #echo sd.floor 0
playsound minecraft:block.amethyst_block.chime player @s ~ ~ ~ 0.6 1.4
execute if score #echo_total sd.floor matches 3.. if score #echo_combo sd.floor matches 0 run function sweetdream_floor:combat/echo_combo
