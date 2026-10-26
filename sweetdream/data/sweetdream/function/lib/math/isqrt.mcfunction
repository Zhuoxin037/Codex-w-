# Input #sq_n >= 0; result #sq_out=floor(sqrt(n)). Bounded Newton iteration.
scoreboard players set #sq_out zx.meta 0
execute unless score #sq_n zx.meta matches 1.. run return 0
scoreboard players set #sq_x zx.meta 40000
execute if score #sq_n zx.meta matches ..100000000 run scoreboard players set #sq_x zx.meta 10000
execute if score #sq_n zx.meta matches ..1000000 run scoreboard players set #sq_x zx.meta 1000
execute if score #sq_n zx.meta matches ..10000 run scoreboard players set #sq_x zx.meta 100
execute if score #sq_n zx.meta matches ..100 run scoreboard players set #sq_x zx.meta 10
function sweetdream:lib/math/isqrt_step
