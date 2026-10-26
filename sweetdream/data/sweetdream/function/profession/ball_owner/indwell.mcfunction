function sweetdream:profession/twin/essence_cap
execute if score @s zx.j_form matches 1 run function sweetdream:profession/twin/essence_self
execute if score @s zx.j_form matches 0 as @e[tag=zx.ball_hit,distance=0..4] run function sweetdream:profession/twin/essence_target
