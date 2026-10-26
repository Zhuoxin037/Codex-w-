scoreboard players remove @s zx.hv_walk 64
function sweetdream:equipment/armor/heart_vein/pump_step
execute if data entity @s {Health:0.0f} run return 0
execute if score @s zx.hv_walk matches 64.. run function sweetdream:equipment/armor/heart_vein/path_steps
