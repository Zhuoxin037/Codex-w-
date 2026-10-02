function sweetdream:equipment/sword/sickle_dreams/sweep/context
data remove storage zx:sweep current
function sweetdream:equipment/sword/sickle_dreams/sweep/read with storage zx:sweep ctx
execute if data storage zx:sweep current run function sweetdream:equipment/sword/sickle_dreams/sweep/restore with storage zx:sweep current
function sweetdream:equipment/sword/sickle_dreams/sweep/forget with storage zx:sweep ctx
tag @s remove zx.sd_sweep
# cast 判手用的临时标签: 正常情况 start 里已经清掉了, 这里再清一次兜底
#   (万一在 start 之前就走到取消 —— 比如施法中掉线又回来)。
tag @s remove zx.sd_off
scoreboard players reset @s zx.sd_t
