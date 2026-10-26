scoreboard players operation #sq_y zx.meta = #sq_n zx.meta
scoreboard players operation #sq_y zx.meta /= #sq_x zx.meta
scoreboard players operation #sq_y zx.meta += #sq_x zx.meta
scoreboard players operation #sq_y zx.meta /= #2 zx.meta
scoreboard players operation #sq_out zx.meta = #sq_x zx.meta
execute if score #sq_y zx.meta >= #sq_x zx.meta run return 0
scoreboard players operation #sq_x zx.meta = #sq_y zx.meta
function sweetdream:lib/math/isqrt_step
