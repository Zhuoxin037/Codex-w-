function sweetdream_floor:combat/open_doors
execute if data storage sweetdream_floor:run current{kind:"boss"} run return run function sweetdream_floor:reward/god_show
scoreboard players add #fights sd.floor 1
scoreboard players add #lumen sd.floor 2
execute if score #hard sd.floor matches 1 run scoreboard players add #fights sd.floor 1
execute if score #hard sd.floor matches 1 run scoreboard players add #lumen sd.floor 1
effect give @s minecraft:instant_health 1 0 true
execute if score #boon sd.floor matches 2 run effect give @s minecraft:instant_health 1 0 true
playsound minecraft:ui.toast.challenge_complete player @s ~ ~ ~ 0.65 1.2
function sweetdream_floor:reward/battle_offer
