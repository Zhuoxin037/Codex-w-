function sweetdream:equipment/sword/sickle_dreams/sweep/context
data remove storage zx:sweep current
function sweetdream:equipment/sword/sickle_dreams/sweep/read with storage zx:sweep ctx
execute if data storage zx:sweep current run function sweetdream:equipment/sword/sickle_dreams/sweep/restore with storage zx:sweep current
function sweetdream:equipment/sword/sickle_dreams/sweep/forget with storage zx:sweep ctx
tag @s remove zx.sd_sweep
scoreboard players reset @s zx.sd_t
