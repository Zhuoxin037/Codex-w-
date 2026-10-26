# Exact decimal long division, including denominators near the scoreboard limit.
scoreboard players set #tf_digit zx.meta 0
scoreboard players set #tf_next zx.meta 0
scoreboard players operation #tf_gap zx.meta = #tf_den zx.meta
scoreboard players operation #tf_gap zx.meta -= #tf_rem zx.meta
scoreboard players set #tf_repeat zx.meta 10
function sweetdream:equipment/armor/tide_fold/ratio_add
scoreboard players operation #tf_rem zx.meta = #tf_next zx.meta
scoreboard players operation #tf_ratio zx.meta *= #10 zx.meta
scoreboard players operation #tf_ratio zx.meta += #tf_digit zx.meta
