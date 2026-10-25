execute if data storage zx:triad_watch player{Health:0.0f} if entity @s[tag=zx.tv_cast] run return run function sweetdream:equipment/staff/triad/visual/end
execute if data storage zx:triad_watch player{Health:0.0f} run return 0
function sweetdream:equipment/staff/triad/visual/model_sync
execute if entity @s[tag=zx.tv_cast] run function sweetdream:equipment/staff/triad/visual/cast_tick
execute if entity @s[tag=zx.tv_cast] run return 0
function sweetdream:equipment/staff/triad/visual/idle
