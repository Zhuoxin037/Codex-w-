scoreboard players set #sm_im zx.meta 1000
execute store result score #sm_im zx.meta run data get storage zx:work pl.independent_multiplier 1000
function manacore:internal/damage/mul_pct {src:"#sm_im",mul:"#sm_pct",obj:"zx.meta"}
execute store result storage zx:work pl.independent_multiplier double 0.001 run scoreboard players get #mul_out zx.meta
