function sweetdream:profession/twin/essence_cap
execute unless score @s zx.j_form matches 0 run return 0
function sweetdream:lib/rnd
scoreboard players operation #jroll zx.meta = #rnd zx.meta
scoreboard players operation #jroll zx.meta %= #j100 zx.meta
execute if score #jroll zx.meta matches ..39 as @e[tag=zx.ball_hit,distance=0..4] run function sweetdream:profession/twin/essence_target
