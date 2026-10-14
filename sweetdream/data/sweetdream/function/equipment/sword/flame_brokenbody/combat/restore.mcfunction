# 每个命中帧重新读取本人的 UUID 列表；临时队列只在当前函数链内使用。
function sweetdream:equipment/sword/flame_brokenbody/combat/context
data remove storage zx:fbcombat current
function sweetdream:equipment/sword/flame_brokenbody/combat/read with storage zx:fbcombat ctx
tag @e[tag=zx.fb_hit,distance=0..] remove zx.fb_hit
execute unless data storage zx:fbcombat current run return 0
data modify storage zx:fbcombat queue set from storage zx:fbcombat current.targets
execute if data storage zx:fbcombat queue[0] run function sweetdream:equipment/sword/flame_brokenbody/combat/target_loop
