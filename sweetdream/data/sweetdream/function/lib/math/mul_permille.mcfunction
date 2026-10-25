# Inputs #mp_src and #mp_mul (zx.meta); output #mp_out. Non-negative damage/multipliers.
scoreboard players operation #mp_q zx.meta = #mp_src zx.meta
scoreboard players operation #mp_q zx.meta /= #1000 zx.meta
scoreboard players operation #mp_q zx.meta *= #mp_mul zx.meta
scoreboard players operation #mp_r zx.meta = #mp_src zx.meta
scoreboard players operation #mp_r zx.meta %= #1000 zx.meta
scoreboard players operation #mp_mq zx.meta = #mp_mul zx.meta
scoreboard players operation #mp_mq zx.meta /= #1000 zx.meta
scoreboard players operation #mp_mr zx.meta = #mp_mul zx.meta
scoreboard players operation #mp_mr zx.meta %= #1000 zx.meta
scoreboard players operation #mp_lo zx.meta = #mp_r zx.meta
scoreboard players operation #mp_lo zx.meta *= #mp_mr zx.meta
scoreboard players operation #mp_lo zx.meta /= #1000 zx.meta
scoreboard players operation #mp_r zx.meta *= #mp_mq zx.meta
scoreboard players operation #mp_out zx.meta = #mp_q zx.meta
scoreboard players operation #mp_out zx.meta += #mp_r zx.meta
scoreboard players operation #mp_out zx.meta += #mp_lo zx.meta
