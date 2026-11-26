scoreboard players set #eh_left zx.meta 0
execute store result score #eh_left zx.meta run data get storage zx:work eh_events[-1].amount
execute if score #eh_left zx.meta matches ..0 run return 0
scoreboard players remove #eh_left zx.meta 1
execute store result storage zx:work eh_events[-1].amount int 1 run scoreboard players get #eh_left zx.meta
function fallendream:equipment/armor/eagle_hat/orb_gain
function fallendream:equipment/armor/eagle_hat/orb_reward
