execute if score #input sd.floor matches 40..42 if score #phase sd.floor matches 4 run return run function sweetdream_floor:reward/god
execute if score #input sd.floor matches 30..37 if score #phase sd.floor matches 3 run return run function sweetdream_floor:reward/pick
execute if score #input sd.floor matches 23 if score #phase sd.floor matches 3 run return run function sweetdream_floor:reward/show
execute if score #input sd.floor matches 23 if score #phase sd.floor matches 4 run return run function sweetdream_floor:reward/god_show
execute if score #input sd.floor matches 23 unless score #phase sd.floor matches 1 run return run function sweetdream_floor:room/status
execute unless score #phase sd.floor matches 1 run return 0
execute unless entity @s[tag=zx.rg_active] run return 0
execute if score #input sd.floor matches 24 run return run function sweetdream_floor:run/boss_shortcut
execute if score #input sd.floor matches 23 run return run function sweetdream_floor:room/help
execute if score #input sd.floor matches 20..22 run function sweetdream_floor:room/select
