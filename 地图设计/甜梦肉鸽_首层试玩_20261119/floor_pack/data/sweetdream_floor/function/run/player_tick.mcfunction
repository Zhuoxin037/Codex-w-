execute unless score @s sd.floor = #serial sd.floor run return run function sweetdream_floor:run/stale
execute if score #phase sd.floor matches 0 run return run function sweetdream_floor:run/stale
execute if score @s sd.floor_death matches 1.. run return run function sweetdream_floor:run/death
execute unless dimension minecraft:overworld run return run function sweetdream_floor:run/death
execute if entity @s[tag=zx.rg_wait] run return run function sweetdream_floor:run/loading
execute if entity @s[tag=zx.rg_prep] run return run function sweetdream_floor:run/loading
execute unless entity @s[tag=zx.rg_active] run return run function sweetdream_floor:run/exit
execute if score #ready sd.floor matches 0 run function sweetdream_floor:run/arrive
execute if score #budget sd.floor matches 0 unless data storage sweetdream_floor:run {exploration_doors:1b} run function sweetdream_floor:room/doors/exhausted
execute if score #phase sd.floor matches 2 run return run function sweetdream_floor:combat/tick
execute unless score #phase sd.floor matches 1 run return 0
execute unless score #last sd.floor = @s zx.rg_room run function sweetdream_floor:room/arrive
