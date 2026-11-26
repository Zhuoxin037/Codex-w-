# dup-ok: hp_pct四次取小数位；余数始终小于最大生命毫点。
scoreboard players operation #hp_rem zx.meta *= #10 zx.meta
scoreboard players operation #hp_digit zx.meta = #hp_rem zx.meta
scoreboard players operation #hp_digit zx.meta /= #max_hp zx.meta
scoreboard players operation #hp_rem zx.meta %= #max_hp zx.meta
scoreboard players operation #hp_p100 zx.meta *= #10 zx.meta
scoreboard players operation #hp_p100 zx.meta += #hp_digit zx.meta
