# 只沿相同规则预检，不移动玩家，也不对路径目标结算。
execute if score #bb_probe_left zx.meta matches ..0 run return run function sweetdream:equipment/staff/burst_bank/probe_end
function sweetdream:equipment/staff/burst_bank/can_move
execute if score #bb_mv zx.meta matches 0 run return run function sweetdream:equipment/staff/burst_bank/probe_end
scoreboard players remove #bb_probe_left zx.meta 1
execute if score #bb_mv zx.meta matches 1 positioned ^ ^ ^0.5 run return run function sweetdream:equipment/staff/burst_bank/probe
execute if score #bb_mv zx.meta matches 2 positioned ^ ^1 ^0.5 run return run function sweetdream:equipment/staff/burst_bank/probe
