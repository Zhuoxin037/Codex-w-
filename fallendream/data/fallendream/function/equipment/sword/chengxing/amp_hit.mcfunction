# Read-only highest multiplier; the value being amplified is #cx_t (attachment).
scoreboard players set @s zx.cx_rdy 0
scoreboard players operation #cx_attachment zx.meta = #cx_t zx.meta
function fallendream:equipment/sword/chengxing/next_amp
scoreboard players operation #mp_src zx.meta = #cx_attachment zx.meta
scoreboard players operation #mp_mul zx.meta = @s zx.cx_amp
function fallendream:lib/math/mul_permille
scoreboard players operation #cx_t zx.meta = #mp_out zx.meta
