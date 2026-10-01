# 此时 @s 仍是玩家，位置/维度来自施法快照；先恢复本次目标，再只打一次。
tag @e[tag=zx.sd_hit] remove zx.sd_hit
data modify storage zx:sweep queue set from storage zx:sweep current.targets
execute if data storage zx:sweep queue[0] run function sweetdream:equipment/sword/sickle_dreams/sweep/target_loop
function sweetdream:lib/uuid
execute if data storage zx:data self{ok:1b} if data storage zx:sweep current{enhanced:0} run function sweetdream:equipment/sword/sickle_dreams/base
execute if data storage zx:data self{ok:1b} if data storage zx:sweep current{enhanced:1} run function sweetdream:equipment/sword/sickle_dreams/enhanced
tag @e[tag=zx.sd_hit] remove zx.sd_hit
