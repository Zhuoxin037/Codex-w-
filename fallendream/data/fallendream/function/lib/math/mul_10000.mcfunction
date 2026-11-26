scoreboard players set #m4_base zx.meta 10000
scoreboard players operation #m4_q zx.meta = #m4_src zx.meta
scoreboard players operation #m4_q zx.meta /= #m4_base zx.meta
scoreboard players operation #m4_r zx.meta = #m4_src zx.meta
scoreboard players operation #m4_r zx.meta %= #m4_base zx.meta
scoreboard players operation #m4_q zx.meta *= #m4_mul zx.meta
scoreboard players operation #m4_r zx.meta *= #m4_mul zx.meta
scoreboard players operation #m4_r zx.meta /= #m4_base zx.meta
scoreboard players operation #m4_out zx.meta = #m4_q zx.meta
scoreboard players operation #m4_out zx.meta += #m4_r zx.meta
